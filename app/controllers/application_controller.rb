class ApplicationController < ActionController::Base
  include Authentication
  allow_browser versions: :modern
  helper_method :current_user
  inertia_share flash: -> { flash.to_hash }

  private
    def current_user
      Current.user
    end
end
