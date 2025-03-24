class ChangeJobTypeColumnActiveToStatus < ActiveRecord::Migration[8.0]
  def change
    remove_column :job_types, :active
    add_column :job_types, :status, :integer, null: false
  end
end
