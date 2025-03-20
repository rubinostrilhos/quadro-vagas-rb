class BulkUploadError < ApplicationRecord
  belongs_to :bulk_upload

  validates :line, :message, presence: true
  validates :line, numericality: { greater_than: 0 }
end
