require 'rails_helper'

describe 'Admin create experience level', type: :system do
  it 'and must be logged in', js: true do
    visit new_experience_level_path

    expect(current_path).to eq new_session_path
  end

  it 'and user must be admin', js: true do
    user = create(:user, role: :regular)
    visit new_session_path
    fill_in 'email_address', with: user.email_address
    fill_in 'password', with: user.password
    click_on 'Sign in'
    sleep 2

    visit new_experience_level_path

    expect(current_path).to eq root_path
  end

  it 'succesfully', js: true do
    user = create(:user, role: :admin)
    visit new_session_path
    fill_in 'email_address', with: user.email_address
    fill_in 'password', with: user.password
    click_on 'Sign in'

    visit new_experience_level_path
    fill_in 'Nome', with: 'Junior'
    select 'Arquivado', from: 'Status'
    click_on 'Salvar'

    expect(page).to have_content 'Junior'
    expect(page).to have_content 'Status: Arquivado'
    expect(page).to have_content 'Editar'
    expect(page).to have_content 'Ativar'
  end

  it 'And creates a active experienced level', js: true do
    user = create(:user, role: :admin)
    visit new_session_path
    fill_in 'email_address', with: user.email_address
    fill_in 'password', with: user.password
    click_on 'Sign in'

    visit new_experience_level_path
    fill_in 'Nome', with: 'Junior'
    select 'Ativo', from: 'Status'
    click_on 'Salvar'

    expect(page).to have_content 'Junior'
    expect(page).to have_content 'Status: Ativo'
    expect(page).to have_content 'Editar'
    expect(page).to have_content 'Arquivar'
  end

  it 'fails with no name inputed', js: true do
    user = create(:user, role: :admin)
    visit new_session_path
    fill_in 'email_address', with: user.email_address
    fill_in 'password', with: user.password
    click_on 'Sign in'

    visit new_experience_level_path
    select 'Ativo', from: 'Status'
    click_on 'Salvar'

    expect(current_path).to eq new_experience_level_path
    expect(page).to have_content 'Nome não pode ficar em branco'
  end

  it 'fails when name is repeated', js: true do
    user = create(:user, role: :admin)
    visit new_session_path
    fill_in 'email_address', with: user.email_address
    fill_in 'password', with: user.password
    click_on 'Sign in'

    experience_level_first = ExperienceLevel.create(
      name: "Junior",
      status: 0
    )

    visit new_experience_level_path
    fill_in 'Nome', with: 'Junior'
    select 'Ativo', from: 'Status'
    click_on 'Salvar'

    expect(current_path).to eq new_experience_level_path
    expect(page).to have_content 'Nome já está em uso'
  end
end
