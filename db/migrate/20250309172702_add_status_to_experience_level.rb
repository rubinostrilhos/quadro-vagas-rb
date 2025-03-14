class AddStatusToExperienceLevel < ActiveRecord::Migration[8.0]
  def change
    add_column :experience_levels, :status, :integer, default: 0
  end
end
