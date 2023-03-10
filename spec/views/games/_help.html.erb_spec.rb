require "rails_helper"

RSpec.describe "games/help", type: :view do
  let(:game) { build_stubbed(:game) }
  let(:help_hash) { {friend_call: "Jane believes that this is an option D"} }

  it "renders help variant" do
    render_partial({}, game)

    expect(rendered).to match "50/50"
    expect(rendered).to match "phone"
    expect(rendered).to match "users"
  end

  it "renders help info text" do
    render_partial(help_hash, game)

    expect(rendered).to match "Jane believes that this is an option D"
  end

  # Check that if the 50/50 hint was used, then such a button is not displayed
  it "does not render used help variant" do
    game.fifty_fifty_used = true

    render_partial(help_hash, game)

    expect(rendered).not_to match "50/50"
  end

  private

  # A method that renders a fragment with the desired objects
  def render_partial(help_hash, game)
    render partial: "games/help", object: help_hash, locals: {game: game}
  end
end