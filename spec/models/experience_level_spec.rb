require 'rails_helper'

RSpec.describe ExperienceLevel, type: :model do
  context "#Valid?" do
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }
    it { define_enum_for(:status) }
  end
end
