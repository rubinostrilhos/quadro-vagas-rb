class ChangeColumnDefaultJobtypeStatus < ActiveRecord::Migration[8.0]
  def change
    change_column_default :job_types, :status, from: nil, to: 0
  end
end
