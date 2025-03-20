require 'rails_helper'

RSpec.describe JobPosting, type: :model do
  context "#Valid?" do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:salary) }
    it { should validate_presence_of(:salary_currency) }
    it { should validate_presence_of(:salary_period) }
    it { should validate_presence_of(:work_arrangement) }
    it { should validate_presence_of(:description) }
    it { should belong_to :company_profile }
    it { should belong_to :job_type }
    it { should belong_to :experience_level }
  end

  context ".tag_list" do
    it "should have 3 tags maximum" do
      job_posting = create(:job_posting)
      job_posting.tag_list = [ 'Ruby', 'Dev Jr', 'Scrum' ]
      job_posting.save!

      job_posting.tag_list.add('teste')
      job_posting.save

      expect(job_posting).not_to be_valid
      expect(job_posting.reload.tag_list.size).to eq 3
      expect(job_posting.errors.full_messages).to include 'Essa vaga já possui o máximo de tags'
    end
  end

  context ".currency_format" do
    it "should return a string in currency format with two decimals" do
      job_posting = create(:job_posting, salary: 10_000)

      expect(job_posting.currency_format).to eq "100.00"
    end
  end

  context 'status' do
    it "should be active if company is active" do
      user = create(:user, status: :active)
      company = create(:company_profile, user: user)
      job_posting = create(:job_posting, company_profile: company)
      expect(job_posting.status).to eq("active")
    end

    it "should be inactive if company is inactive" do
      user = create(:user, status: :inactive)
      company = create(:company_profile, user: user)
      job_posting = create(:job_posting, company_profile: company)
      expect(job_posting.status).to eq("inactive")
    end
  end
end
