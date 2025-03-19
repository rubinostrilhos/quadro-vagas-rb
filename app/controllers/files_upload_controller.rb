class FilesUploadController < ApplicationController
  before_action :check_user_is_admin
  def new
  end

  def create
    if params[:file].present?
      file = params[:file]
      file_path = Rails.root.join("tmp", file.original_filename)
      File.open(file_path, "wb") { |f| f.write(file.read) }

      ProcessFileJob.perform_later(file_path.to_s)
      flash[:notice] = "Arquivo enviado com sucesso. Processando arquivo..."
      redirect_to processing_path
      return
    else
      flash[:alert] = "Nenhum arquivo selecionado."
      return
    end
    redirect_to new_files_upload_path
  end

  private

  def check_user_is_admin
    unless Current.user.admin?
      redirect_to new_session_path
    end
  end
end
