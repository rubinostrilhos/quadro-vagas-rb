require 'rails_helper'

describe "Visitor search for jobs by title and description", type: :system do
  it 'successfuly' do
    company_profile = create(:company_profile)
    junior = create(:experience_level, name: 'Junior')
    pleno = create(:experience_level, name: 'Pleno')
    senior = create(:experience_level, name: 'Senior')
    create(:job_posting, title: "RUBY on Rails Dev Jr.", description: "Rails dev Jr", company_profile: company_profile, experience_level: junior)
    create(:job_posting, title: "Sinatra Developer Jr.", description: "Ruby developer", company_profile: company_profile, experience_level: junior)
    create(:job_posting, title: "Sinatra Dev Pl.", description: "Clean Architecture", company_profile: company_profile, experience_level: pleno)
    create(:job_posting, title: "Rails Developer Pl.", description: "TDD e RSpec", company_profile: company_profile, experience_level: pleno)
    create(:job_posting, title: "DragonRuby Game Dev Sr.", description: "Game Developer", company_profile: company_profile, experience_level: senior)

    visit root_path
    fill_in "query", with: "ruby"
    find("#search_button").click

    expect(page).to have_content "RUBY on Rails Dev Jr."
    expect(page).to have_content "Sinatra Developer Jr."
    expect(page).to have_content "DragonRuby Game Dev Sr."
    expect(page).not_to have_content "Sinatra Dev Pl."
    expect(page).not_to have_content "Rails Developer Pl."
  end

  it 'and search empty' do
    company_profile = create(:company_profile)
    junior = create(:experience_level, name: 'Junior')
    pleno = create(:experience_level, name: 'Pleno')
    senior = create(:experience_level, name: 'Senior')
    create(:job_posting, title: "RUBY on Rails Dev Jr.", description: "Rails dev Jr", company_profile: company_profile, experience_level: junior)
    create(:job_posting, title: "Sinatra Developer Jr.", description: "Ruby developer", company_profile: company_profile, experience_level: junior)
    create(:job_posting, title: "Sinatra Dev Pl.", description: "Clean Architecture", company_profile: company_profile, experience_level: pleno)
    create(:job_posting, title: "Rails Developer Pl.", description: "TDD e RSpec", company_profile: company_profile, experience_level: pleno)
    create(:job_posting, title: "DragonRuby Game Dev Sr.", description: "Game Developer", company_profile: company_profile, experience_level: senior)

    visit root_path
    fill_in "query", with: ""
    find("#search_button").click

    expect(page).to have_content "Por favor, digite algum valor para a busca"
    expect(page).to have_content "RUBY on Rails Dev Jr."
    expect(page).to have_content "DragonRuby Game Dev Sr."
    expect(page).to have_content "Sinatra Developer Jr."
    expect(page).to have_content "Sinatra Dev Pl."
    expect(page).to have_content "Rails Developer Pl."
  end

  it 'and not found jobs' do
    company_profile = create(:company_profile)
    junior = create(:experience_level, name: 'Junior')
    pleno = create(:experience_level, name: 'Pleno')
    senior = create(:experience_level, name: 'Senior')
    create(:job_posting, title: "RUBY on Rails Dev Jr.", description: "Rails dev Jr", company_profile: company_profile, experience_level: junior)
    create(:job_posting, title: "Sinatra Developer Jr.", description: "Ruby developer", company_profile: company_profile, experience_level: junior)
    create(:job_posting, title: "Sinatra Dev Pl.", description: "Clean Architecture", company_profile: company_profile, experience_level: pleno)
    create(:job_posting, title: "Rails Developer Pl.", description: "TDD e RSpec", company_profile: company_profile, experience_level: pleno)
    create(:job_posting, title: "DragonRuby Game Dev Sr.", description: "Game Developer", company_profile: company_profile, experience_level: senior)

    visit root_path
    fill_in "query", with: "Node"
    find("#search_button").click

    expect(page).to have_content "Nenhuma vaga encontrada."
    expect(page).not_to have_content "Please enter a search term."
    expect(page).not_to have_content "Ruby on Rails Dev Jr."
    expect(page).not_to have_content "DragonRuby Game Dev Sr."
    expect(page).not_to have_content "Sinatra Developer Jr."
    expect(page).not_to have_content "Sinatra Dev Pl."
    expect(page).not_to have_content "Rails Developer Pl."
  end
end
