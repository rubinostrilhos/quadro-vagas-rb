class AddOwnStatusToJobPostings < ActiveRecord::Migration[8.0]
  def change
    add_column :job_postings, :own_status, :integer, default: 0, null: false
  end
end
