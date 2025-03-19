class AddCountsToImportedFiles < ActiveRecord::Migration[8.0]
  def change
    add_column :imported_files, :user_created, :integer
    add_column :imported_files, :company_profile_created, :integer
    add_column :imported_files, :job_posting_created, :integer
  end
end
