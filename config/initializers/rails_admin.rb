RailsAdmin.config do |config|
  config.asset_source = :webpack
  config.authorize_with do
    redirect_to main_app.root_path unless current_user.is_admin?
  end

  config.authenticate_with do
    warden.authenticate! scope: :user
  end
  config.current_user_method(&:current_user)

  config.included_models = ['Question', 'Game', 'User']

  config.actions do
    dashboard                     # mandatory
    index                         # mandatory
    new
    export
    bulk_delete
    show
    edit
    delete
    show_in_app
  end
end
