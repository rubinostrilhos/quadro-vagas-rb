class FilesUploadController < ApplicationController
  before_action :check_user_is_admin
  def new
  end

  def create
    file = params[:file]

    file_path = Rails.root.join("tmp", file.original_filename)
    puts file_path
  end

  private

  def check_user_is_admin
    unless Current.user.admin?
      redirect_to new_session_path
    end
  end
end
