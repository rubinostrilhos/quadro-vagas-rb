require 'rails_helper'

describe "Visitor sees job postings", type: :system do
  it "successfully" do
    first_user = create(:user)
    rubyoncloud = create(:company_profile, name: "Ruby on cloud", website_url: "http://rubyoncloud.com", contact_email: "contact@rubyoncloud.com", user: first_user)
    full_time_job = JobType.create!(name: "full time")
    pleno = create(:experience_level, name: 'Pleno')
    create(:job_posting, title: "Dev Rails", salary: "1000.00", salary_currency: :usd, salary_period: :monthly, job_type: full_time_job, description: "Software Developer", company_profile: rubyoncloud, experience_level: pleno)

    second_user = create(:user, email_address: 'second@user.com')
    second_company = create(:company_profile, user: second_user, contact_email: 'second@company.com')
    second_job_posting = create(:job_posting, company_profile: second_company, experience_level: pleno)
    third_job_posting = create(:job_posting, company_profile: second_company, experience_level: pleno)

    visit root_path

    expect(page).to have_content("Dev Rails")
    expect(page).to have_content("Ruby on cloud")
    expect(page).to have_content("full time")
    expect(page).to have_content(second_job_posting.title)
    expect(page).to have_content(second_job_posting.company_profile.name)
    expect(page).to have_content(second_job_posting.job_type.name)
    expect(page).to have_content(third_job_posting.title)
    expect(page).to have_content(third_job_posting.company_profile.name)
    expect(page).to have_content(third_job_posting.job_type.name)
    expect(page).not_to have_content("Nenhuma vaga disponível no momento.")
  end

  it "and cant see inactive job postings" do
    first_user = create(:user, status: :active)
    first_company = create(:company_profile, name: "Ruby on cloud", website_url: "http://rubyoncloud.com", contact_email: "contact@rubyoncloud.com", user: first_user)
    second_user = create(:user, email_address: 'second@user.com', status: :active)
    second_company = create(:company_profile, name: "Microsoft", website_url: "http://microsoft.com", contact_email: "contact@microsoft.com", user: second_user)
    job_type = create(:job_type, name: 'Júnior')
    create(:job_posting, title: "Dev Rails", description: "Software Developer", company_profile: first_company, job_type: job_type)
    create(:job_posting, title: "Dev Node", company_profile: second_company, job_type: job_type)
    second_user.toggle_status!

    visit root_path

    expect(page).to have_content("Dev Rails")
    expect(page).not_to have_content("Dev Node")
  end

  it "and there are no job postings" do
    visit root_path

    expect(page).to have_content("Nenhuma vaga disponível no momento.")
  end

  it "and not see archived job posting" do
    experience_level_jr = ExperienceLevel.create(
      name: "Junior",
      status: :archived
    )
    first_user = create(:user, email_address: 'first@email.com')
    first_company = create(:company_profile, user: first_user, contact_email: 'first@company.com')
    rails_job = create(:job_posting, title: "Ruby on Rails Dev Jr.", status: :archived, company_profile: first_company, experience_level: experience_level_jr)
    second_user = create(:user, email_address: 'second@email.com')
    second_company = create(:company_profile, user: second_user, contact_email: 'second@company.com')
    django_job = create(:job_posting, title: "Django Dev Jr.", status: :published, company_profile: second_company, experience_level: experience_level_jr)

    visit root_path

    expect(page).not_to have_content rails_job.title
    expect(page).to have_content django_job.title
  end
end
