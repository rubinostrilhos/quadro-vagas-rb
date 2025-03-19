class BulkUpload < ApplicationRecord
  belongs_to :user
  has_one_attached :file

  enum :status, { pending: 0, processing: 10, completed: 20 }
end
