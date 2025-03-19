class AddErrorCountToImportedFiles < ActiveRecord::Migration[8.0]
  def change
    add_column :imported_files, :error_count, :integer
  end
end
