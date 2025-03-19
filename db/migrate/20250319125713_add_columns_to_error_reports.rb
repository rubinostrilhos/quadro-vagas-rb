class AddColumnsToErrorReports < ActiveRecord::Migration[8.0]
  def change
    add_column :error_reports, :row_data, :text
    add_column :error_reports, :line, :integer, default: 0
  end
end
