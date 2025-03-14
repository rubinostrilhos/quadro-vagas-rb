require 'rails_helper'

describe 'Admin edit experience level', type: :system do
  it 'and must be logged in', js: true do
    experience_level = create(:experience_level, name: "Junior")

    visit edit_experience_level_path(experience_level.id)

    expect(current_path).to eq new_session_path
  end

  it 'and user must be admin', js: true do
    user = create(:user, role: :regular)
    visit new_session_path
    fill_in 'email_address', with: user.email_address
    fill_in 'password', with: user.password
    click_on 'Sign in'
    sleep 2
    experience_level = create(:experience_level, name: "Junior")

    visit edit_experience_level_path(experience_level.id)

    expect(current_path).to eq root_path
  end

  it 'succesfully', js: true do
    user = create(:user, role: :admin)
    visit new_session_path
    fill_in 'email_address', with: user.email_address
    fill_in 'password', with: user.password
    click_on 'Sign in'
    create(:experience_level, name: "Junior", status: :archived)

    visit experience_levels_path
    click_on 'Editar'
    fill_in 'Nome', with: 'Pleno'
    click_on 'Salvar'

    expect(page).to have_content 'Pleno'
    expect(page).to have_content 'Status: Arquivado'
    expect(page).to have_content 'Editar'
    expect(page).to have_content 'Ativar'
  end

  it 'fail when name is empty', js: true do
    user = create(:user, role: :admin)
    visit new_session_path
    fill_in 'email_address', with: user.email_address
    fill_in 'password', with: user.password
    click_on 'Sign in'
    create(:experience_level, name: "Junior")

    visit experience_levels_path
    click_on 'Editar'
    fill_in 'Nome', with: ''
    click_on 'Salvar'

    expect(page).to have_content 'Nome não pode ficar em branco'
  end

  it 'fails when name is repeated', js: true do
    user = create(:user, role: :admin)
    visit new_session_path
    fill_in 'email_address', with: user.email_address
    fill_in 'password', with: user.password
    click_on 'Sign in'
    create(:experience_level, name: "Junior")
    experience_level_second = create(:experience_level, name: "Pleno")

    visit experience_levels_path
    within "#experience_level_#{experience_level_second.id}" do
      click_on 'Editar'
    end
    fill_in 'Nome', with: 'Junior'
    click_on 'Salvar'

    expect(page).to have_content 'Nome já está em uso'
  end
end
