class AddStatusToJobPostings < ActiveRecord::Migration[8.0]
  def change
    add_column :job_postings, :status, :integer, default: 0, null: false
  end
end
