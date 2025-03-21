class AddProcessedAndSuccessfulLinesToBulkUploads < ActiveRecord::Migration[8.0]
  def change
    add_column :bulk_uploads, :successful_lines, :integer, default: 0
  end
end
