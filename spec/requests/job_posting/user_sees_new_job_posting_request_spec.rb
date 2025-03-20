require 'rails_helper'

describe 'User tries to see a job posting', type: :request do
  context 'and fails for being unauthenticated' do
    it 'for create a new job postings' do
      get(new_job_posting_path)

      expect(response).to redirect_to new_session_path
      expect(response.status).to eq 302
    end

    it 'for index of job postings' do
      get(job_postings_path)

      expect(response).to redirect_to new_session_path
      expect(response.status).to eq 302
    end
  end
end
