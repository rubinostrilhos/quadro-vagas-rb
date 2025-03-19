class CreateBulkUploads < ActiveRecord::Migration[8.0]
  def change
    create_table :bulk_uploads do |t|
      t.integer :status, default: 0
      t.integer :total_lines
      t.integer :errors_count
      t.string :file
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
