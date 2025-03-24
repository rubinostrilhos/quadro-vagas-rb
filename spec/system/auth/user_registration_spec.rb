require 'rails_helper'

describe 'User registration', type: :system do
  it 'successfully' do
    visit new_registration_path

    fill_in 'Nome', with: 'João'
    fill_in 'Sobrenome', with: 'Silva'
    fill_in 'E-mail', with: 'joao@email.com'
    fill_in 'Senha', with: 'password123'
    fill_in 'Confirmação de Senha', with: 'password123'
    click_on 'Cadastrar'

    expect(page).to have_content 'Usuário criado com sucesso.'

    visit root_path

    within 'header nav' do
      expect(page).to have_button 'Sair'
    end
  end

  it 'cannot create user with blank fields' do
    visit new_registration_path

    fill_in 'Nome', with: ''
    fill_in 'Sobrenome', with: ''
    fill_in 'E-mail', with: ''
    fill_in 'Senha', with: ''
    fill_in 'Confirmação de Senha', with: ''

    click_on 'Cadastrar'

    expect(page).to have_content 'Erro ao criar usuário.'

    expect(page).to have_content 'Nome não pode ficar em branco'
    expect(page).to have_content 'Sobrenome não pode ficar em branco'
    expect(page).to have_content 'E-mail não pode ficar em branco'
    expect(page).to have_content 'Senha não pode ficar em branco'
  end

  it 'show a messagem with invalid email' do
    visit new_registration_path

    fill_in 'Nome', with: 'João'
    fill_in 'Sobrenome', with: 'Silva'
    fill_in 'E-mail', with: 'joao@email'
    fill_in 'Senha', with: 'password123'
    fill_in 'Confirmação de Senha', with: 'password123'

    click_on 'Cadastrar'

    expect(page).to have_content 'Erro ao criar usuário.'

    expect(page).to have_content 'E-mail não é válido'
  end

  it 'show a messagem if passwords do not match' do
    visit new_registration_path

    fill_in 'Nome', with: 'João'
    fill_in 'Sobrenome', with: 'Silva'
    fill_in 'E-mail', with: 'joao@email.com'
    fill_in 'Senha', with: 'password123'
    fill_in 'Confirmação de Senha', with: 'password'

    click_on 'Cadastrar'

    expect(page).to have_content 'Erro ao criar usuário.'

    expect(page).to have_content 'Confirmação de Senha não é igual a Senha'
  end
end
