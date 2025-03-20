class RemoveErrorsCountFromBulkUploads < ActiveRecord::Migration[8.0]
  def change
    remove_column :bulk_uploads, :errors_count, :integer
  end
end
