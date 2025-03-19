class AddLineCountToImportFiles < ActiveRecord::Migration[8.0]
  def change
    add_column :imported_files, :lines_count, :integer, default: 0
  end
end
