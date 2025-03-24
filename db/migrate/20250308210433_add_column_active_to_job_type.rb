class AddColumnActiveToJobType < ActiveRecord::Migration[8.0]
  def change
    add_column :job_types, :active, :boolean
  end
end
