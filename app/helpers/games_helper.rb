# This file will be loaded automatically when drawing the template
# We will put into it all the auxiliary methods that we want to use in the templates,
# # related to the display of games
module GamesHelper
  # This method will draw a convenient label to show the status of the game
  # # We use the standard bootstrap class `label`
  def game_label(game)
    if game.status == :in_progress && current_user == game.user
      link_to content_tag(:span, t("game_statuses.#{game.status}"), class: 'label'), game_path(game)
    else
      content_tag :span, t("game_statuses.#{game.status}"), class: 'label label-danger'
    end
  end
end
