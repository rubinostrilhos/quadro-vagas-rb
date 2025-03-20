class BulkUploadsController < ApplicationController
  before_action :only_admin_access, only: %i[ new create show ]

  def new; end

  def create
    uploaded_file = params[:file]

    if uploaded_file.nil?
      flash.now[:alert] = "Please, select a file"
      return render :new, status: :unprocessable_entity
    end

    file_path = Rails.root.join("tmp", uploaded_file.original_filename)

    if !text_file?(file_path)
      flash.now[:alert] = "Please, select a valid text file"
      return render :new, status: :unprocessable_entity
    end

    File.open(file_path, "wb") { |file| file.write(uploaded_file.read) }

    bulk_upload = BulkUpload.new(user: Current.user, total_lines: File.readlines(file_path).size)
    bulk_upload.file.attach(uploaded_file)

    if bulk_upload.save
      ProcessBulkUploadFileJob.perform_later(bulk_upload.id, file_path.to_s)
      redirect_to bulk_upload_path(bulk_upload), notice: "Your file is being processed"
    else
      flash.now[:alert] = "Failed to upload file"
      render :new, status: :unprocessable_entity
    end
  end

  def show
    redis = Redis.new(url: ENV["REDIS_URL"])

    bulk_upload_id = params[:id]

    @bulk_upload = BulkUpload.find_by(id: bulk_upload_id)
    @processed = redis.get("bulk-upload-#{bulk_upload_id}-processed-lines").to_i
    @successful = redis.get("bulk-upload-#{bulk_upload_id}-successful").to_i
    @errors = redis.get("bulk-upload-#{bulk_upload_id}-errors-count").to_i
    @errors_details = JSON.parse(redis.get("bulk-upload-#{bulk_upload_id}-errors-details") || "[]")
  end

  private

  def text_file?(file_path)
    text_extensions = %w[.txt]
    text_extensions.include?(File.extname(file_path).downcase)
  end
end
