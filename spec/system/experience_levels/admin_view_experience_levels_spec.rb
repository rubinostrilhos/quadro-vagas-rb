require 'rails_helper'

describe 'Admin view experience levels list', type: :system do
  it 'and must be logged in', js: true do
    visit experience_levels_path

    expect(current_path).to eq new_session_path
  end

  it 'and must be logged in', js: true do
    visit root_path

    expect(page).not_to have_content 'Níveis de Experiência'
  end

  it 'succesfully', js: true  do
    user = create(:user, role: :admin)
    visit new_session_path
    fill_in 'email_address', with: user.email_address
    fill_in 'password', with: user.password
    click_on 'Sign in'
    experience_level_first = ExperienceLevel.create(
      name: "Junior",
      status: :archived
    )
    experience_level_second = ExperienceLevel.create(
      name: "Pleno",
      status: :active
    )

    visit root_path
    click_on 'Níveis de Experiência'

    expect(page).to have_content 'Junior'
    expect(page).to have_content 'Status: Arquivado'
    expect(page).to have_content 'Pleno'
    expect(page).to have_content 'Status: Ativo'
  end

  it 'and there is no experience level', js: true  do
    user = create(:user, role: :admin)
    visit new_session_path
    fill_in 'email_address', with: user.email_address
    fill_in 'password', with: user.password
    click_on 'Sign in'

    visit experience_levels_path

    expect(page).to have_content 'Não há nìveis de experiência cadastradados'
  end
end
