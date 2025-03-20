require 'rails_helper'

describe 'User tries to create job post', type: :request do
  it 'and fails for not being authenticated' do
    post(job_postings_path, params: { job_posting: {
        title: 'Desenvolvedor'
      } })

    expect(response).to redirect_to new_session_path
    expect(response.status).to eq 302
  end

  it 'successfully' do
    user = create(:user)
    company = create(:company_profile, user: user)
    job_type = create(:job_type)
    experience_level = create(:experience_level)

    login_as(user)
    post(job_postings_path, params: { job_posting: {
      title: "Dev React", salary: "1000",
      salary_currency: :usd, salary_period: :monthly, work_arrangement: :remote,
      job_type_id: job_type.id, experience_level_id: experience_level.id,
      description: "There’s", tag_list: [ 'Rails', 'RSpec', 'Ruby' ]
    } })

    expect(JobPosting.count).to eq 1
    expect(flash[:notice]).to eq 'Anúncio criado com sucesso'
    job_posting = JobPosting.last
    expect(job_posting.title).to eq 'Dev React'
    expect(job_posting.salary).to eq 0.1e4
    expect(job_posting.salary_currency).to eq "usd"
    expect(job_posting.salary_period).to eq "monthly"
    expect(job_posting.work_arrangement).to eq "remote"
    expect(job_posting.description.to_plain_text).to eq "There’s"
    expect(job_posting.tag_list).to eq [ 'rails', 'rspec', 'ruby' ]
  end

  it 'and maximum tags should be 3' do
    user = create(:user)
    company = create(:company_profile, user: user)
    job_type = create(:job_type)
    experience_level = create(:experience_level)

    login_as(user)
    post(job_postings_path, params: { job_posting: {
      title: "Dev React", salary: "1000",
      salary_currency: :usd, salary_period: :monthly, work_arrangement: :remote,
      job_type_id: job_type.id, experience_level_id: experience_level.id,
      description: "There’s", tag_list: [ 'Rails', 'RSpec', 'Ruby', 'Inválido' ]
    } })

    expect(JobPosting.count).to eq 0
    expect(flash[:alert]).to eq 'Erro ao tentar criar Anúncio da vaga'
  end
end
