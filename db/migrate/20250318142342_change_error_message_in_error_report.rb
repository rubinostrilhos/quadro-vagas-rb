class ChangeErrorMessageInErrorReport < ActiveRecord::Migration[8.0]
  def change
    reversible do
      change_column :error_reports, :error_message, "VARCHAR[]", using: "ARRAY[error_message]::VARCHAR[]"
    end
  end
end
