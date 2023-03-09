require "rails_helper"

# We begin to describe the functionality for creating a game
RSpec.feature "USER creates a game", type: :feature do
  # Готовим базу: создаём пользователя
  let(:user) { create :user }

  # As well as 15 questions with different levels of difficulty
  # Please note the text of the question and answer options
  let!(:questions) do
    (0..14).to_a.map do |i|
      create(
        :question, level: i,
        text: "When was america discovered #{i}?",
        answer1: "1380", answer2: "1381", answer3: "1382", answer4: "1383"
      )
    end
  end

  before do
    login_as user
  end

  scenario "success" do
    visit "/"

    click_link "New game"

    expect(page).to have_content("When was america discovered 0?")

    expect(page).to have_content("1380")
    expect(page).to have_content("1381")
    expect(page).to have_content("1382")
    expect(page).to have_content("1383")

    save_and_open_page
  end
end