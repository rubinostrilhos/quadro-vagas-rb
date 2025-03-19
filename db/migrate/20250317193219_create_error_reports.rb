class CreateErrorReports < ActiveRecord::Migration[8.0]
  def change
    create_table :error_reports do |t|
      t.references :imported_file, null: false, foreign_key: true

      t.timestamps
    end
  end
end
