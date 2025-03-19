class ProcessingChannel < ApplicationCable::Channel
  def subscribed
    stream_from "processing"
  end
end
