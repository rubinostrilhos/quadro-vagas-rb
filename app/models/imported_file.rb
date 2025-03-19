class ImportedFile < ApplicationRecord
  belongs_to :user
  has_many :error_reports
  has_one_attached :file

  enum :status, { ongoing: 0, done: 10 }

  after_update_commit do
    broadcast_replace_to "imported_file_#{self.id}",
      target: "file_report_#{self.id}",
      partial: "imported_files/imported_file",
      locals: { imported_file: self }
  end

  def to_csv
    bom = "\uFEFF"
    bom + CSV.generate(col_sep: ";", encoding: "UTF-8") do |csv|
      csv << [ "Linha", "Erros", "Dados da linha" ]

      error_reports.each do |error|
        csv << [ error.line, error.errors_list, error.row_data ]
      end
    end
  end
end
