class CreateBulkUploadErrors < ActiveRecord::Migration[8.0]
  def change
    create_table :bulk_upload_errors do |t|
      t.references :bulk_upload, null: false, foreign_key: true
      t.integer :line, null: false
      t.string :message, null: false

      t.timestamps
    end
  end
end
