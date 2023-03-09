class Game < ApplicationRecord

  # cash prize for each question
  PRIZES = [
    100, 200, 300, 500, 1000,
    2000, 4000, 8000, 16000, 32000,
    64000, 125000, 250000, 500000, 1000000
  ].freeze

  # numbers of fireproof levels
  FIREPROOF_LEVELS = [4, 9, 14].freeze

  # time for one game
  TIME_LIMIT = 35.minutes

  belongs_to :user

  # array of game questions for this game
  has_many :game_questions, dependent: :destroy

  validates :user, presence: true

  # current question (its difficulty level)
  validates :current_level, numericality: { only_integer: true }, allow_nil: false

  # # the player's winnings are from zero to the maximum prize per game
  validates :prize,
            presence: true,
            numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: PRIZES.last }

  # Scope - subset of games where the finished_at field is empty
  scope :in_progress, -> { where(finished_at: nil) }

  #---------  Factory-generator of a new game ------------------------------

  # returns correct new game or dies with exceptions
  def self.create_game_for_user!(user)
    # inside a single transaction
    transaction do
      game = create!(user: user)

      # we add exactly 15 new game questions to the created game by choosing a random Question from the database
      Question::QUESTION_LEVELS.each do |i|
        q = Question.where(level: i).order('RANDOM()').first
        ans = [1, 2, 3, 4]
        game.game_questions.create!(question: q, a: ans.shuffle!.pop, b: ans.shuffle!.pop, c: ans.shuffle!.pop, d: ans.shuffle!.pop)
      end
      game
    end
  end

  #---------  The main methods of accessing the state of the game ------------------

  #the last answered question of the game, *nil* for a new game!
  def previous_game_question
    # using the ruby detect method, we find the necessary question in the game_questions array
    game_questions.detect { |q| q.question.level == previous_level }
  end

  # the current, still unanswered question of the game
  def current_game_question
    game_questions.detect { |q| q.question.level == current_level }
  end

  # -1 for a new game!
  def previous_level
    current_level - 1
  end

  # The game is over if the field is specified :finished_at - end time of the game
  def finished?
    finished_at.present?
  end

  # checks the current time and crashes the game + returns true if the time has passed
  def time_out!
    if (Time.now - created_at) > TIME_LIMIT
      finish_game!(fire_proof_prize(previous_level), true)
      true
    end
  end

  #---------  Basic game methods------------------------------------

  # returns true — if the answer is correct,
  # the current game updates its state at the same time:
  #   changes :current_level, :prize (if the level is fireproof), fields :updated_at
  #   prescribed :finished_at if it was the last question
  #
  # returns false — if 1) the answer is incorrect 2) time is up 3) the game is already over earlier
  # in any case, it is prescribed :finished_at, :prize (if the level is fireproof), :updated_at
  # After calling this method, the game status will be updated
  #
  # letter = 'a','b','c' или 'd'
  def answer_current_question!(letter)
    return false if time_out! || finished? # a finished game cannot be updated

    if current_game_question.answer_correct?(letter)
      if current_level == Question::QUESTION_LEVELS.max
        self.current_level += 1
        finish_game!(PRIZES[Question::QUESTION_LEVELS.max], false)
      else
        self.current_level += 1
        save!
      end

      true
    else
      finish_game!(fire_proof_prize(previous_level), true)
      false
    end
  end

  # We write the game amount to the user's account and end the game,
  def take_money!
    return if time_out! || finished? # there is nothing to take from a finished or unpacked game
    finish_game!((previous_level > -1) ? PRIZES[previous_level] : 0, false)
  end

  # help_type = :fifty_fifty | :audience_help | :friend_call

  def use_help(help_type)
    case help_type
    when :fifty_fifty
      unless fifty_fifty_used
        # ActiveRecord метод toggle! switches the boolean field immediately in the database
        toggle!(:fifty_fifty_used)
        current_game_question.add_fifty_fifty
        return true
      end
    when :audience_help
      unless audience_help_used
        toggle!(:audience_help_used)
        current_game_question.add_audience_help
        return true
      end
    when :friend_call
      unless friend_call_used
        toggle!(:friend_call_used)
        current_game_question.add_friend_call
        return true
      end
    end

    false
  end

  # The result of the game, one of:
  # :fail - the game is lost due to an incorrect question
  # :timeout - the game is lost due to timeout
  # :won - the game is won (all 15 questions are conquered)
  # :money - the game is over, the player has taken the money
  # :in_progress - the game is still on
  def status
    return :in_progress unless finished?

    if is_failed
      if (finished_at - created_at) <= TIME_LIMIT
        :fail
      else
        :timeout
      end
    else
      if current_level > Question::QUESTION_LEVELS.max
        :won
      else
        :money
      end
    end
  end

  private

  # Game finalizer method
  # Updates all the necessary fields and charges the user a win
  def finish_game!(amount = 0, failed = true)

    # wrap in a transaction - the game ends
    # and the user's balance is replenished only together
    transaction do
      self.prize = amount
      self.finished_at = Time.now
      self.is_failed = failed
      user.balance += amount
      save!
      user.save!
    end
  end

  #According to the given level of the question, we calculate the reward for the nearest fireproof amount
  # noinspection RubyArgCount
  def fire_proof_prize(answered_level)
    lvl = FIREPROOF_LEVELS.select { |x| x <= answered_level }.last
    lvl.present? ? PRIZES[lvl] : 0
  end
end
