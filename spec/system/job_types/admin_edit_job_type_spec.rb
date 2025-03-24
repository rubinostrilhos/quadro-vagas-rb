require 'rails_helper'

describe 'admin edits job type', type: :system do
  it 'with success' do
    admin = create(:user, role: :admin)
    job_type = create(:job_type, name: 'Estágio', status: :active)

    login_as admin
    visit edit_job_type_path(job_type)
    fill_in 'Nome',	with: 'Pleno'
    select 'Arquivado', from: 'Status'
    click_on 'Salvar'

    expect(current_path).to eq job_types_path
    expect(page).to have_content 'Tipo de vaga editada com sucesso'
    expect(page).not_to have_content 'Estágio'
    expect(page).to have_content 'Pleno'
    expect(page).not_to have_content 'Ativado'
    expect(page).to have_content 'Arquivado'
  end

  it 'user must be admin' do
    regular = create(:user, role: :regular)
    job_type = create(:job_type, name: 'Estágio', status: :active)

    login_as(regular)
    visit edit_job_type_path(job_type.id)

    expect(current_path).to eq root_path
    expect(page).to have_content 'Acesso não autorizado'
  end

  it 'user must be authenticated' do
    job_type = create(:job_type, name: 'Estágio', status: :active)

    visit edit_job_type_path(job_type.id)

    expect(current_path).to eq new_session_path
  end

  it 'and name is required' do
    admin = create(:user, role: :admin)
    job_type = create(:job_type, name: 'Estágio', status: :active)

    login_as admin
    visit edit_job_type_path(job_type)
    fill_in 'Nome',	with: ''
    select 'Arquivado', from: 'Status'
    click_on 'Salvar'

    expect(page).to have_content 'Não foi possível editar'
    expect(page).to have_content 'Nome não pode ficar em branco'
  end
end
