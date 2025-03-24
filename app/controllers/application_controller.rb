class ApplicationController < ActionController::Base
  include Authentication
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  private

  def only_admin_access
    redirect_to root_path, alert: I18n.t("unauthorized") unless admin?
  end
end
