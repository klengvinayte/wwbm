require 'rails_helper'

RSpec.describe 'users/_game', type: :view do
  let(:game) do
    build_stubbed(
      :game, id: 15, created_at: Time.parse('2023.01.27, 23:30'), current_level: 10, prize: 1000
    )
  end

  before(:each) do
    allow(game).to receive(:status).and_return(:in_progress)

    render partial: 'users/game', object: game
  end

  it 'renders game id' do
    expect(rendered).to match '15'
  end

  it 'renders game start time' do
    expect(rendered).to match '27 Jan 21:30'
  end

  it 'renders game current question' do
    expect(rendered).to match '10'
  end

  it 'renders game status' do
    expect(rendered).to match 'in progress'
  end

  it 'renders game prize' do
    expect(rendered).to match '€1,000'
  end
end