require 'rails_helper'

describe 'Visitante visita tela inicial' do
  it 'com sucesso' do
    visit root_path

    expect(page).to have_content 'Quadro de Vagas'
  end
end
