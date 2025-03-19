class ImportedFilesController < ApplicationController
  before_action :check_user_is_admin
  before_action :validate_file, only: %i[ create ]

  def new
    @imported_file = Current.user.imported_files.build
  end

  def create
    @imported_file =  Current.user.imported_files.build(file_name: params[:imported_file][:name])
    @imported_file.file.attach(params[:imported_file][:file])

    if @imported_file.save!
      update_lines_total
      ImportFilesJob.perform_later(@imported_file)
      redirect_to @imported_file, notice: "Arquivo processado com sucesso!"
    else
      render :new
    end
  end

  def show
    @imported_file = ImportedFile.find(params[:id])
    redirect_to root_path, alert: "Você não tem acesso a sessa página" unless Current.user == @imported_file.user
  end

  def download_errors_file
    @imported_file = ImportedFile.find(params[:imported_file_id])
    return redirect_to @imported_file, alert: "O arquivo ainda está sendo processado" unless @imported_file.done?
    respond_to do |format|
      format.html
      format.csv do
        send_data @imported_file.to_csv, filename: "#{@imported_file.file_name} #{Date.today.strftime('%d-%m-%Y')}-#{@imported_file.id}.csv", type: "text/csv; charset=utf-8"
      end
    end
  end
  private

  def check_user_is_admin
    redirect_to root_path, alert: "Você não tem acesso a essa página" unless Current.user.admin?
  end

  def validate_file
    return redirect_to new_imported_file_path, alert: "É necessário selecionar um arquivo para enviá-lo" unless params[:imported_file][:file]

    allowed_content_types = [ "text/plain", "text/csv" ]
    redirect_to new_imported_file_path, alert: "Apenas arquivos CSV e TXT são permitidos" unless allowed_content_types.include?(params[:imported_file][:file].content_type)
  end

  def update_lines_total
    file_path = ActiveStorage::Blob.service.path_for(@imported_file.file.key)
    lines_total = File.foreach(file_path).count
    @imported_file.update(lines_total: lines_total)
  end
end
