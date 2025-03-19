class AddLinesTotalToImportedFiles < ActiveRecord::Migration[8.0]
  def change
    add_column :imported_files, :lines_total, :integer, default: 0
    add_column :imported_files, :status, :integer, default: 0
  end
end
