class CreateImportedFiles < ActiveRecord::Migration[8.0]
  def change
    create_table :imported_files do |t|
      t.string :file_name

      t.timestamps
    end
  end
end
