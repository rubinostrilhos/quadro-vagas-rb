class AddErrorToErrorReport < ActiveRecord::Migration[8.0]
  def change
    add_column :error_reports, :error, :string
  end
end
