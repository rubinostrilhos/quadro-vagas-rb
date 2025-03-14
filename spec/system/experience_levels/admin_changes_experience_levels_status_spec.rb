require 'rails_helper'

describe 'Admin changes experience level status', type: :system do
  it 'sucefuly', js: true  do
    user = create(:user, role: :admin)
    visit new_session_path
    fill_in 'email_address', with: user.email_address
    fill_in 'password', with: user.password
    click_on 'Sign in'
    sleep 2
    experience_level_first = ExperienceLevel.create(
      name: "Junior",
      status: :archived
    )

    visit experience_levels_path
    click_on "Ativar"

    expect(page).to have_content 'Junior'
    expect(page).to have_content 'Status: Ativo'
  end
end
