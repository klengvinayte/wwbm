require 'rails_helper'

RSpec.describe GameQuestion, type: :model do
  let(:game_question) { FactoryBot.create(:game_question, a: 2, b: 1, c: 4, d: 3) }

  context "game status" do
    it "correct .variants" do
      expect(game_question.variants).to eq({
                                             "a" => game_question.question.answer2,
                                             "b" => game_question.question.answer1,
                                             "c" => game_question.question.answer4,
                                             "d" => game_question.question.answer3
                                           })
    end

    it "correct .answer_correct?" do
      expect(game_question.answer_correct?("b")).to be_truthy
    end

    it "text" do
      expect(game_question.text).to eq(game_question.question.text)
    end

    it "level" do
      expect(game_question.level).to eq(game_question.question.level)
    end
  end

  describe "#correct_answer_key" do
    it "correct .correct_answer_key" do
      expect(game_question.correct_answer_key).to eq("b")
    end
  end

  describe "#user_helpers" do
    context "audience_help" do

      it "checks that the field is empty by default" do
        expect(game_question.help_hash).not_to include(:audience_help)
      end

      it "checks that the field is not empty after take help" do
        game_question.add_audience_help
        expect(game_question.help_hash).to include(:audience_help)
      end

      it "checks keys" do
        game_question.add_audience_help
        expect(game_question.help_hash[:audience_help].keys).to contain_exactly("a", "b", "c", "d")
      end
    end

    context "fifty_fifty" do

      it "checks that the field is empty by default" do
        expect(game_question.help_hash).not_to include(:fifty_fifty)
      end

      it "checks that the field is not empty after take help" do
        game_question.add_fifty_fifty
        expect(game_question.help_hash).to include(:fifty_fifty)
      end

      it "checks the number of remaining answer options" do
        game_question.add_fifty_fifty
        ff = game_question.help_hash[:fifty_fifty]
        expect(ff.size).to be 2
      end

      it "checks that the correct option should remain" do
        game_question.add_fifty_fifty
        ff = game_question.help_hash[:fifty_fifty]
        expect(ff).to include("b")
      end
    end

    context "friend_call" do
      it "checks that the field is empty by default" do
        expect(game_question.help_hash).not_to include(:friend_call)
      end

      it "checks that the field is not empty after take help" do
        game_question.add_friend_call

        expect(game_question.help_hash).to include(:friend_call)
      end
      it "checks that the correct option should remain" do
        game_question.add_friend_call
        expect(game_question.help_hash[:friend_call]).to include("B")
      end
    end
  end

  describe "#help_hash" do
    it "has an empty hash " do
      expect(game_question.help_hash).to eq({})
    end

    it "saves successfully" do
      game_question.help_hash[:some_key1] = "aaa"
      game_question.help_hash[:some_key2] = "bbb"

      expect(game_question.save).to be_truthy

      gq = GameQuestion.find(game_question.id)

      expect(gq.help_hash).to eq({ some_key1: "aaa", some_key2: "bbb" })
    end
  end
end
