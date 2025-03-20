require 'rails_helper'

RSpec.describe BulkUploadError, type: :model do
  describe 'associations' do
    it { should belong_to(:bulk_upload) }
  end

  describe 'validations' do
    it { should validate_presence_of(:line) }
    it { should validate_numericality_of(:line).is_greater_than(0) }
    it { should validate_presence_of(:message) }
  end

  describe 'creating an error log' do
    let(:bulk_upload) { create(:bulk_upload) }

    it 'creates a valid BulkUploadError' do
      error_log = BulkUploadError.new(
        bulk_upload: bulk_upload,
        line: 3,
        message: "Invalid email format"
      )

      expect(error_log).to be_valid
      expect { error_log.save }.to change(BulkUploadError, :count).by(1)
    end

    it 'is invalid without a line' do
      error_log = BulkUploadError.new(bulk_upload: bulk_upload, message: "Invalid data")
      expect(error_log).to_not be_valid
      expect(error_log.errors[:line]).to include("não pode ficar em branco")
    end

    it 'is invalid with a line number of zero or negative' do
      error_log = BulkUploadError.new(bulk_upload: bulk_upload, line: 0, message: "Invalid data")
      expect(error_log).to_not be_valid
      expect(error_log.errors[:line]).to include("deve ser maior que 0")
    end

    it 'is invalid without a message' do
      error_log = BulkUploadError.new(bulk_upload: bulk_upload, line: 2)
      expect(error_log).to_not be_valid
      expect(error_log.errors[:message]).to include("não pode ficar em branco")
    end
  end
end
