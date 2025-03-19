class ImportedFilesChannel < ApplicationCable::Channel
  def subscribed
     stream_from "imported_files_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
