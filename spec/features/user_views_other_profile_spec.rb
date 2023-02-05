require "rails_helper"

RSpec.feature "USER views another profile", type: :feature do
  let(:game_user) { create :user, name: "Kris" }

  let!(:games) do
    [
      create(
        :game,
        user: game_user,
        is_failed: true,
        current_level: 6,
        prize: 1000,
        created_at: "2023-01-28, 14:39 UTC".to_datetime,
        finished_at: "2023-01-28, 14:42 UTC".to_datetime
      ),
      create(
        :game,
        user: game_user,
        current_level: 15,
        prize: 1000000,
        created_at: "2023-01-30, 08:01 UTC".to_datetime,
        finished_at: "2023-01-30, 08:07 UTC".to_datetime
      )
    ]
  end

  scenario "successfully" do
    visit "/users/#{game_user.id}"

    expect(page).to have_content(game_user.name)

    expect(page).to have_content("28 янв., 14:39")
    expect(page).to have_content("30 янв., 08:01")

    expect(page).to have_content("победа")
    expect(page).to have_content("проигрыш")

    expect(page).to have_content("1 000 000 ₽")
    expect(page).to have_content("1 000 ₽")

    expect(page).to have_content("50/50 phone users")

    expect(page).to have_content("15")
    expect(page).to have_content("6")

    expect(page).not_to have_content("Сменить имя и пароль")
  end
end
