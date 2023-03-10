require "game_help_generator"

class GameQuestion < ApplicationRecord
  belongs_to :game
  # the question from which all the information is taken
  belongs_to :question

  # we create virtual getters text, level in this model, the values of which are
  # automatically taken from the related question model
  delegate :text, :level, to: :question, allow_nil: true

  validates :game, :question, presence: true

  # fields a,b,c,d hide the indexes of responses from the object :game
  validates :a, :b, :c, :d, inclusion: { in: 1..4 }

  # Automatic serialization of the field into the database (we use it as a regular hash,
  # and the rails in the database are stored as a string)
  serialize :help_hash, Hash

  # help_hash has this format:
  # {
  #   fifty_fifty: ['a', 'b'], # When using the hint, options a and b remained
  #   audience_help: {'a' => 42, 'c' => 37 ...}, # Distribution of votes by options a, b, c, d
  #   friend_call: 'Harry Potter believes that the correct answer is A'
  # }
  #

  # ----- Basic methods for accessing data in templates and controllers -----------

  # Returns a hash sorted by keys:
  # {"a" => "Answer text Х", "b" => "Answer text У", ... }
  def variants
    {
      "a" => question.read_attribute("answer#{a}"),
      "b" => question.read_attribute("answer#{b}"),
      "c" => question.read_attribute("answer#{c}"),
      "d" => question.read_attribute("answer#{d}")
    }
  end

  # Returns true if the passed letter (string or character) contains the correct answer
  def answer_correct?(letter)
    correct_answer_key == letter.to_s.downcase
  end

  # the key to the correct answer "a", "b", "c", или "d"
  def correct_answer_key
    { a => "a", b => "b", c => "c", d => "d" }[1]
  end

  # the text of the correct answer
  def correct_answer
    variants[correct_answer_key]
  end

  # Add an array of two options to help_hash using the fifty_fifty key: correct and random
  # and save the object
  def add_fifty_fifty
    self.help_hash[:fifty_fifty] = [
      correct_answer_key,
      (%w(a b c d) - [correct_answer_key]).sample
    ]
    save
  end

  # Generate a random distribution of options in help_hash and save the object
  def add_audience_help
    # array of keys
    keys_to_use = keys_to_use_in_help
    self.help_hash[:audience_help] = GameHelpGenerator.audience_distribution(keys_to_use, correct_answer_key)
    save
  end

  # Adding a friend"s hint to help_hash and saving the object
  def add_friend_call
    # array of keys
    keys_to_use = keys_to_use_in_help
    self.help_hash[:friend_call] = GameHelpGenerator.friend_call(keys_to_use, correct_answer_key)
    save
  end

  def apply_help!(help_type)
    case help_type.to_s
    when :fifty_fifty
      add_fifty_fifty
    when :audience_help
      add_audience_help
    when :friend_call
      add_friend_call
    end
  end

  private

  # We calculate which keys are available to us in the hints
  def keys_to_use_in_help
    keys_to_use = variants.keys
    # We take into account the presence of a 50/50 hint
    keys_to_use = help_hash[:fifty_fifty] if help_hash.has_key?(:fifty_fifty)
    keys_to_use
  end
end
