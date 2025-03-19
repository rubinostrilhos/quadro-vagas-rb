class ProcessingController < ApplicationController
  before_action :check_user_is_admin

  def show
  end

  private

  def check_user_is_admin
    unless Current.user.admin?
      redirect_to new_session_path
    end
  end
end
