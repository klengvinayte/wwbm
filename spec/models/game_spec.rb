require "rails_helper"
require "support/my_spec_helper"

RSpec.describe Game, type: :model do
  let(:user) { create(:user) }

  let(:game_w_questions) { create(:game_with_questions, user: user) }

  context "Game Factory" do
    it "Game.create_game! new correct game" do
      generate_questions(60)

      game = nil
      expect {
        game = Game.create_game_for_user!(user)
      }.to change(Game, :count).by(1).and(
        change(GameQuestion, :count).by(15).and(
          change(Question, :count).by(0)
        )
      )

      expect(game.user).to eq(user)
      expect(game.status).to eq(:in_progress)

      expect(game.game_questions.size).to eq(15)
      # Проверяем массив уровней
      expect(game.game_questions.map(&:level)).to eq (0..14).to_a
    end
  end

  context "game mechanics" do
    it "answer correct continues" do
      level = game_w_questions.current_level
      q = game_w_questions.current_game_question

      expect(game_w_questions.status).to eq(:in_progress)

      game_w_questions.answer_current_question!(q.correct_answer_key)

      expect(game_w_questions.current_level).to eq(level +1)

      expect(game_w_questions.previous_game_question).to eq q
      expect(game_w_questions.current_game_question).not_to eq q
      expect(game_w_questions.status).to eq(:in_progress)
      expect(game_w_questions.finished?).to be_falsey
    end

    it "take money! finishes the game" do
      q = game_w_questions.current_game_question
      game_w_questions.answer_current_question!(q.correct_answer_key)
      game_w_questions.take_money!
      prize = game_w_questions.prize

      expect(prize).to be > 0
      expect(user.balance).to eq prize
      expect(game_w_questions.finished?).to be_truthy
      expect(game_w_questions.status).to eq :money
    end
  end

  context ".status" do
    before(:each) do
      game_w_questions.finished_at = Time.now
      expect(game_w_questions.finished?).to be_truthy

      it ":won" do
        game_w_questions.current_level = Question::QUESTION_LEVELS.max + 1
        expect(game_w_questions.status).to eg(:won)
      end

      it ":fail" do
        game_w_questions.is_failed = false
        expect(game_w_questions.status).to eq(:fail)
      end

      it ":timeout" do
        game_w_questions.created_at = 1.hour.ago
        game_w_questions.is_failed = true
        expect(game_w_questions.status).to eq(:timeout)
      end

      it ":money" do
        expect(game_w_questions.status).to eq(:money)
      end
    end
  end

  describe "#current_game_question" do
    it "returns current game question" do
      expect(game_w_questions.current_game_question).to eq(game_w_questions.game_questions[0])
    end
  end

  describe "#previous_level" do
    it "checks correctness .previous_level" do
      expect(game_w_questions.previous_level).to eq(-1)
    end
  end

  context "#answer_current_question!" do
    it "check right answer" do
      expect(game_w_questions.answer_current_question!("d")).to eq(true)
      expect(game_w_questions.status).to eq(:in_progress)
    end

    it "check wrong answer" do
      expect(game_w_questions.answer_current_question!("b")).to eq(false)
      expect(game_w_questions.status).to eq(:fail)
    end

    it "check last win answer status" do
      game_w_questions.current_level = Question::QUESTION_LEVELS.max
      expect(game_w_questions.answer_current_question!("d")).to eq(true)
    end

    it "check last win answer level" do
      game_w_questions.current_level = Question::QUESTION_LEVELS.max
      game_w_questions.answer_current_question!("d")
      expect(game_w_questions.current_level).to eq(Question::QUESTION_LEVELS.max + 1)
    end

    it "check answer after timeout" do
      game_w_questions.created_at = 1.hour.ago
      expect(game_w_questions.answer_current_question!("b")).to eq(false)
    end
  end
end
