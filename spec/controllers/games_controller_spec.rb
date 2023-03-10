require "rails_helper"
# Сразу подключим наш модуль с вспомогательными методами
require "support/my_spec_helper"

RSpec.describe GamesController, type: :controller do
  # обычный пользователь
  let(:user) { create(:user) }
  # админ
  let(:admin) { create(:user, is_admin: true) }
  # игра с прописанными игровыми вопросами
  let(:game_w_questions) { create(:game_with_questions, user: user) }

  describe "#show" do
    context "anon" do
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

    context "Usual user" do
      before do
        sign_in user
        get :show, params: { id: game_w_questions.id }
      end

      it "continues the game" do
        game = assigns(:game)
        expect(game.finished?).to be false
      end

      it "has user" do
        game = assigns(:game)
        expect(game.user).to eq(user)
      end

      it "has response status" do
        expect(response.status).to eq(200)
      end

      it "displays the correct template" do
        expect(response).to render_template("show")
      end
    end
  end

  describe "#create" do
    context "anon" do
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

    context "Usual user" do
      before do
        sign_in user
        generate_questions(60)
      end

      context "first game" do
        before do
          post :create
        end

        it "continues the game" do
          game = assigns(:game)
          expect(game.finished?).to be false
        end

        it "has user" do
          game = assigns(:game)
          expect(game.user).to eq(user)
        end

        it "redirects to game" do
          game = assigns(:game)
          expect(response).to redirect_to game_path(game)
        end

        it "has notice" do
          game = assigns(:game)
          expect(flash[:notice]).to be
        end
      end

      context "Usual user is trying to create a second game" do
        let!(:existing_game) { game_w_questions }

        it "continues current game" do
          expect(game_w_questions.finished?).to be false
        end

        it "does not create new records" do
          expect { post :create }.to change(Game, :count).by(0)
        end

        it "does not create a new game" do
          post :create
          game = assigns(:game)
          expect(game).to be nil
        end

        it "redirects to current game" do
          post :create
          expect(response).to redirect_to(game_path(existing_game))
        end

        it "has alert flash" do
          post :create
          expect(flash[:alert]).to be
        end
      end
    end
  end

  describe "#answer" do
    context "anon" do
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

    context "Usual user" do

      context "answer correct" do
        before do
          sign_in user
          put :answer, params: { id: game_w_questions.id, letter: game_w_questions.current_game_question.correct_answer_key }
        end

        it "continues the game" do
          game = assigns(:game)
          expect(game.finished?).to be false
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
          sign_in user
          put :answer, params: { id: game_w_questions.id, letter: "a" }
        end

        it "not continues the game" do
          game = assigns(:game)
          expect(game.finished?).to be true
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
  end

  describe "#take_money" do
    context "anon" do
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
  end

  describe "#help" do
    context "anon" do
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

  describe "dont show another game" do
    context "Usual user" do
      before do
        sign_in user
        alien_game = FactoryBot.create(:game_with_questions)
        get :show, params: { id: alien_game.id }
      end

      it "has response status" do
        expect(response.status).not_to eq(200)
      end

      it "redirects to root_path" do
        expect(response).to redirect_to root_path
      end

      it "has alert" do
        expect(flash[:alert]).to be
      end
    end
  end

  describe "take money before finish game" do
    context "Usual user" do
      before do
        sign_in user
        game_w_questions.update_attribute(:current_level, 2)

        put :take_money, params: { id: game_w_questions.id }
      end

      it "not continues the game" do
        game = assigns(:game)
        expect(game.finished?).to be true
      end

      it "has a prize" do
        game = assigns(:game)
        expect(game.prize).to eq(200)
      end

      it "updates balance" do
        user.reload
        expect(user.balance).to eq(200)
      end

      it "redirects to user_path" do
        user.reload
        expect(response).to redirect_to(user_path(user))
      end

      it "has warning flash" do
        user.reload
        expect(flash[:warning]).to be
      end
    end
  end

  describe "#use_help" do
    context "uses audience_help" do
      before do
        sign_in user
      end

      it "has an empty hash" do
        expect(game_w_questions.current_game_question.help_hash[:audience_help]).not_to be
      end

      it "has a false field" do
        expect(game_w_questions.audience_help_used).to be false
      end

      it "continues the game" do
        put :help, params: { id: game_w_questions.id, help_type: :audience_help }
        game = assigns(:game)

        expect(game.finished?).to be false
      end

      it "has a true field" do
        put :help, params: { id: game_w_questions.id, help_type: :audience_help }
        game = assigns(:game)

        expect(game.audience_help_used).to be true
      end

      it "has a non-empty hash" do
        put :help, params: { id: game_w_questions.id, help_type: :audience_help }
        game = assigns(:game)

        expect(game.current_game_question.help_hash[:audience_help]).to be
      end

      it "checks keys" do
        put :help, params: { id: game_w_questions.id, help_type: :audience_help }
        game = assigns(:game)

        expect(game.current_game_question.help_hash[:audience_help].keys).to contain_exactly("a", "b", "c", "d")
      end

      it "redirects to current game page" do
        put :help, params: { id: game_w_questions.id, help_type: :audience_help }
        game = assigns(:game)

        expect(response).to redirect_to(game_path(game))
      end
    end

    context "fifty_fifty" do
      before do
        sign_in user
      end

      it "has an empty hash" do
        expect(game_w_questions.current_game_question.help_hash[:fifty_fifty]).not_to be
      end

      it "has a false field" do
        expect(game_w_questions.audience_help_used).to be false
      end

      it "continues the game" do
        put :help, params: { id: game_w_questions.id, help_type: :fifty_fifty }
        game = assigns(:game)

        expect(game.finished?).to be false
      end

      it "has a true field" do
        put :help, params: { id: game_w_questions.id, help_type: :fifty_fifty }
        game = assigns(:game)

        expect(game.fifty_fifty_used).to be true
      end

      it "has a non-empty hash" do
        put :help, params: { id: game_w_questions.id, help_type: :fifty_fifty }
        game = assigns(:game)

        expect(game.current_game_question.help_hash[:fifty_fifty]).to be
      end

      it "checks keys" do
        put :help, params: { id: game_w_questions.id, help_type: :fifty_fifty }
        game = assigns(:game)

        expect(game.current_game_question.help_hash[:fifty_fifty]).to include(  "d")
      end

      it "redirects to current game page" do
        put :help, params: { id: game_w_questions.id, help_type: :fifty_fifty }
        game = assigns(:game)

        expect(response).to redirect_to(game_path(game))
      end
    end
  end
end
