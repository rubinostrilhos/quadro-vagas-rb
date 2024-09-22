require 'rails_helper'

describe 'Usuário se cadastra' do
  it 'com sucesso' do

    visit root_path
    click_on 'Cadastrar usuário'
    fill_in "E-mail",	with: "user@email.com"
    fill_in "Senha",	with: "password123"
    fill_in "Confirmar senha",	with: "password123"
    click_on 'Salvar'

    expect(page).to have_content 'Usuário cadastrado com sucesso!'
  end
end
