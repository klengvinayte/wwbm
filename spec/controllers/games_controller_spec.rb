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
    it "kick from #show" do
      get :show, params: { id: game_w_questions.id }

      expect(response.status).not_to eq 200
      expect(response).to redirect_to(new_user_session_path)
      expect(flash[:alert]).to be
    end

    it "kick from #create" do
      post :create

      expect(response.status).not_to eq 200
      expect(response).to redirect_to(new_user_session_path)
      expect(flash[:alert]).to be
    end

    it "kick from #answer" do
      put :answer, params: { id: game_w_questions.id }

      expect(response.status).not_to eq 200
      expect(response).to redirect_to(new_user_session_path)
      expect(flash[:alert]).to be
    end

    it "kick from #take_money" do
      put :take_money, params: { id: game_w_questions.id }

      expect(response.status).not_to eq 200
      expect(response).to redirect_to(new_user_session_path)
      expect(flash[:alert]).to be
    end

    it "kick from #help" do
      put :help, params: { id: game_w_questions.id }

      expect(response.status).not_to eq 200
      expect(response).to redirect_to(new_user_session_path)
      expect(flash[:alert]).to be
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

    it "answer correct" do
      put :answer, params: { id: game_w_questions.id, letter: game_w_questions.current_game_question.correct_answer_key }

      game = assigns(:game)

      expect(game.finished?).to be_falsey
      expect(game.current_level).to be > 0
      expect(response).to redirect_to game_path(game)
      expect(flash.empty?).to be_truthy
    end

    it "answer incorrect" do
      put :answer, params: { id: game_w_questions.id, letter: "a" }

      game = assigns(:game)

      expect(game.finished?).to be_truthy
      expect(game.current_level).to be 0
      expect(response).to redirect_to(user_path(user))
      expect(flash[:alert]).to be
      expect(game.prize).to be 0
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