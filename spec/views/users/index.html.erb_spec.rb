require 'rails_helper'

RSpec.describe 'users/index', type: :view do
  before do
    assign(:users, [
      build_stubbed(:user, name: 'Kris', balance: 5000),
      build_stubbed(:user, name: 'Alex', balance: 3000),
    ])

    render
  end

  it 'renders player names' do
    expect(rendered).to match 'Kris'
    expect(rendered).to match 'Alex'
  end

  it 'renders player balances' do
    expect(rendered).to match '5 000 ₽'
    expect(rendered).to match '3 000 ₽'
  end

  it 'renders player names in right order' do
    expect(rendered).to match /Kris.*Alex/m
  end
end