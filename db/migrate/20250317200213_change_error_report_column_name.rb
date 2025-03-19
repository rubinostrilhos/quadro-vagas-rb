class ChangeErrorReportColumnName < ActiveRecord::Migration[8.0]
  def change
    rename_column :error_reports, :error, :error_message
  end
end
