class AlterTypeSalaryForIntegerInJobPostings < ActiveRecord::Migration[8.0]
  def up
    change_column :job_postings, :salary, :integer
  end

  def down
    change_column :job_postings, :salary, :decimal
  end
end
