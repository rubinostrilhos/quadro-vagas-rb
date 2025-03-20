class ProcessBulkUploadFileJob < ApplicationJob
  queue_as :default

  def perform(bulk_upload_id, file_path)
    redis_client = Redis.new(url: ENV["REDIS_URL"])
    bulk_upload = BulkUpload.find_by(id: bulk_upload_id)

    lines = File.readlines(file_path)
    bulk_upload.update(status: 10)

    redis_keys = {
      processed: "bulk-upload-#{bulk_upload.id}-processed-lines",
      successful: "bulk-upload-#{bulk_upload.id}-successful",
      error_count: "bulk-upload-#{bulk_upload.id}-errors-count",
      error_details: "bulk-upload-#{bulk_upload.id}-errors-details"
    }

    redis_client.mset(
      redis_keys[:processed], 0,
      redis_keys[:successful], 0,
      redis_keys[:error_count], 0,
      redis_keys[:error_details], [].to_json
    )

    lines.each_with_index { |line, index| ProcessBulkUploadDataJob.perform_later(bulk_upload.id, index, line) }

    bulk_upload.update(status: 20)

    File.delete(file_path) if File.exist?(file_path)
  end
end
