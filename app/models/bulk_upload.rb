class BulkUpload < ApplicationRecord
  belongs_to :user
  has_one_attached :file
  has_many :bulk_upload_errors

  enum :status, { pending: 0, processing: 10, completed: 20 }
end
