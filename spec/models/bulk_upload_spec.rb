require 'rails_helper'

RSpec.describe BulkUpload, type: :model do
  describe 'enum' do
    it { should define_enum_for(:status).with_values(pending: 0, processing: 10, completed: 20) }

    it "has default status as pending" do
      bulk_upload = BulkUpload.new
      expect(bulk_upload.status).to eq("pending")
    end
  end
end
