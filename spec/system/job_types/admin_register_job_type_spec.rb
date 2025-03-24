require 'rails_helper'

describe 'admin registers job type', type: :system do
  it 'through the job types index page' do
    admin = create(:user, role: :admin)

    login_as admin
    visit root_path
    click_on 'Tipos de Vagas'
    click_on 'Novo Tipo de Vaga'

    expect(current_path).to eq new_job_type_path
  end

  it 'with status active' do
    admin = create(:user, role: :admin)

    login_as admin
    visit new_job_type_path
    fill_in 'Nome',	with: 'Estágio'
    select 'Ativo', from: 'Status'
    click_on 'Salvar'

    expect(current_path).to eq job_types_path
    expect(page).to have_content 'Tipo de vaga criada com sucesso'
    expect(page).to have_content 'Estágio'
    expect(JobType.last.status).to eq 'active'
  end

  it 'with status archived' do
    admin = create(:user, role: :admin)

    login_as admin
    visit new_job_type_path
    fill_in 'Nome',	with: 'Estágio'
    select 'Arquivado', from: 'Status'
    click_on 'Salvar'

    expect(current_path).to eq job_types_path
    expect(page).to have_content 'Tipo de vaga criada com sucesso'
    expect(page).to have_content 'Estágio'
    expect(JobType.last.status).to eq 'archived'
  end

  it 'only admin users are allowed to create a job type' do
    regular = create(:user, role: :regular)

    login_as regular

    visit new_job_type_path

    expect(current_path).to eq root_path
    expect(page).to have_content 'Acesso não autorizado'
  end

  it 'user must be authenticated' do
    visit new_job_type_path

    expect(current_path).to eq new_session_path
  end

  it 'name is required' do
    admin = create(:user, role: :admin)

    login_as admin
    visit new_job_type_path
    fill_in 'Nome',	with: ''
    click_on 'Salvar'

    expect(page).to have_content 'Não foi possível criar o tipo de vaga'
    expect(page).to have_content 'Nome não pode ficar em branco'
  end
end
