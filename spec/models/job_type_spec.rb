require 'rails_helper'

RSpec.describe JobType, type: :model do
  describe '#Valid?' do
    context 'Nome' do
      it { should validate_presence_of(:name) }
      subject { build(:job_type) }
      it { should validate_uniqueness_of(:name) }
    end

    context 'Status' do
      it { should define_enum_for(:status).with_values(active: 0, archived: 10).with_default(:active) }
    end
  end
end
