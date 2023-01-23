require 'rails_helper'
# Сразу подключим наш модуль с вспомогательными методами
require 'support/my_spec_helper'

RSpec.describe GamesController, type: :controller do
  # обычный пользователь
  let(:user) { FactoryBot.create(:user) }
  # админ
  let(:admin) { FactoryBot.create(:user, is_admin: true) }
  # игра с прописанными игровыми вопросами
  let(:game_w_questions) { FactoryBot.create(:game_with_questions, user: user) }

  context "anon" do
    describe "#show" do
      before do
        get :show, params: { id: game_w_questions.id }
      end

      it "has response status" do
        expect(response.status).not_to eq 200
      end
      it "redirects to sign in" do
        expect(response).to redirect_to(new_user_session_path)
      end
      it "has alert" do
        expect(flash[:alert]).to be
      end
    end

    describe "#create" do
      before do
        post :create
      end

      it "has response status" do
        expect(response.status).not_to eq 200
      end
      it "redirects to sign in" do
        expect(response).to redirect_to(new_user_session_path)
      end
      it "has alert" do
        expect(flash[:alert]).to be
      end
    end

    describe "#answer" do
      before do
        put :answer, params: { id: game_w_questions.id }
      end

      it "has response status" do
        expect(response.status).not_to eq 200
      end
      it "redirects to sign in" do
        expect(response).to redirect_to(new_user_session_path)
      end
      it "has alert" do
        expect(flash[:alert]).to be
      end
    end

    describe "#take_money" do
      before do
        put :take_money, params: { id: game_w_questions.id }
      end

      it "has response status" do
        expect(response.status).to eq 302
      end
      it "redirects to sign in" do
        expect(response).to redirect_to(new_user_session_path)
      end
      it "has alert" do
        expect(flash[:alert]).to be
      end
    end

    describe "#help" do
      before do
        put :help, params: { id: game_w_questions.id }
      end

      it "has response status" do
        expect(response.status).to eq 302
      end
      it "redirects to sign in" do
        expect(response).to redirect_to(new_user_session_path)
      end
      it "has alert" do
        expect(flash[:alert]).to be
      end
    end
  end

  context "Usual user" do
    before(:each) do
      sign_in user
    end

    it "creates game" do
      generate_questions(60)
      post :create

      game = assigns(:game)

      expect(game.finished?).to be_falsey
      expect(game.user).to eq(user)

      expect(response).to redirect_to game_path(game)
      expect(flash[:notice]).to be
    end

    it "show game" do
      get :show, params: { id: game_w_questions.id }

      game = assigns(:game)
      expect(game.finished?).to be_falsey
      expect(game.user).to eq(user)

      expect(response.status).to eq(200)
      expect(response).to render_template("show")
    end

    describe "#answer" do

      context "answer correct" do
        before do
          put :answer, params: { id: game_w_questions.id, letter: game_w_questions.current_game_question.correct_answer_key }
        end

        it "continues the game" do
          game = assigns(:game)
          expect(game.finished?).to be_falsey
        end

        it "changes current level" do
          game = assigns(:game)
          expect(game.current_level).to be > 0
        end

        it "redirect to current game" do
          game = assigns(:game)
          expect(response).to redirect_to game_path(game)
        end

        it "has no notification" do
          expect(flash.empty?).to be_truthy
        end
      end

      context "answer incorrect" do
        before do
          put :answer, params: { id: game_w_questions.id, letter: "a" }
        end

        it "not continues the game" do
          game = assigns(:game)
          expect(game.finished?).to be_truthy
        end

        it "not changes current level" do
          game = assigns(:game)
          expect(game.current_level).to be 0
        end

        it "redirect to current user" do
          expect(response).to redirect_to(user_path(user))
        end

        it "has alert notification" do
          expect(flash[:alert]).to be
        end

        it "has no prize" do
          game = assigns(:game)
          expect(game.prize).to be 0
        end
      end
    end

    it "dont show another game" do
      alien_game = FactoryBot.create(:game_with_questions)

      get :show, params: { id: alien_game.id }

      expect(response.status).not_to eq(200)
      expect(response).to redirect_to root_path
      expect(flash[:alert]).to be
    end

    it "take money before finish game" do
      game_w_questions.update_attribute(:current_level, 2)

      put :take_money, params: { id: game_w_questions.id }
      game = assigns(:game)

      expect(game.finished?).to be_truthy
      expect(game.prize).to eq(200)

      user.reload
      expect(user.balance).to eq(200)
      expect(response).to redirect_to(user_path(user))
      expect(flash[:warning]).to be
    end

    it "try to create second game" do
      expect(game_w_questions.finished?).to be_falsey

      expect { post :create }.to change(Game, :count).by(0)

      game = assigns(:game)

      expect(game).to be nil
      expect(response).to redirect_to(game_path(game_w_questions))
      expect(flash[:alert]).to be
    end
  end
end