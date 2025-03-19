class AddColumnToErrorReport < ActiveRecord::Migration[8.0]
  def change
    add_column :error_reports, :errors_list, :text
  end
end
