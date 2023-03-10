class UsersController < ApplicationController
  before_action :set_user, only: [:show]

  def index
    # For the rating page, we will need all users sorted by winnings
    @users = User.all.order(balance: :desc)
  end

  def show
    # For the user profile, we will need all the games in the order of prescription
    @games = @user.games.order(created_at: :desc)
  end

  private

  def set_user
    @user = User.find(params[:id])
  end
end
