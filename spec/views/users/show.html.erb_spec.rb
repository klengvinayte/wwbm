require 'rails_helper'

RSpec.describe 'users/show', type: :view do
  let(:user) { create(:user, name: 'Kris') }

  context "user views not own profile" do

    before do
      sign_in user
      assign(:games, [stub_template("users/_game.html.erb" => "game template")])
      assign(:user, user)

      render
    end

    it 'renders player names' do
      expect(rendered).to match 'Kris'
    end

    it "renders games" do
      expect(rendered).to match 'game template'
    end

    it "renders password changing link" do
      expect(rendered).to match(link_to 'Сменить имя и пароль', edit_user_registration_path(user))
    end
  end

  context "user views not own profile" do
    it 'does not render password changing link' do
      assign(:user, user)
      expect(rendered).not_to match(link_to 'Сменить имя и пароль', edit_user_registration_path(user))
    end
  end
end