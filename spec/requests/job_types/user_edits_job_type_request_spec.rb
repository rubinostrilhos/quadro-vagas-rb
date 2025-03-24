require 'rails_helper'

describe 'User edits job_type', type: :request do
  it 'success' do
    admin = create(:user, role: :admin)
    job_type = create(:job_type, name: 'Estágio', status: :active)

    login_as admin
    patch job_type_path(job_type.id), params: { job_type: {
      name: 'Pleno',
      status: :archived
    } }

    expect(response).to redirect_to job_types_path
    expect(JobType.last.name).to eq 'Pleno'
    expect(JobType.last.status).to eq 'archived'
  end

  it 'user must be admin' do
    regular = create(:user, role: :regular)
    job_type = create(:job_type, name: 'Estágio', status: :active)

    login_as regular
    patch job_type_path(job_type.id), params: { job_type: {
      name: 'Pleno',
      status: :archived
    } }

    expect(response).to redirect_to root_path
    expect(flash[:alert]).to eq 'Acesso não autorizado'
    expect(JobType.last.name).to eq 'Estágio'
    expect(JobType.last.status).to eq 'active'
  end

  it 'user must be authenticated' do
    job_type = create(:job_type, name: 'Estágio', status: :active)

    patch job_type_path(job_type.id), params: { job_type: {
      name: 'Pleno',
      status: :archived
    } }

    expect(response).to redirect_to new_session_path
    expect(JobType.last.name).to eq 'Estágio'
    expect(JobType.last.status).to eq 'active'
  end

  it 'name is required' do
    admin = create(:user, role: :admin)
    job_type = create(:job_type, name: 'Estágio', status: :active)

    login_as(admin)
    patch job_type_path(job_type.id), params: { job_type: {
      name: '',
      status: :archived
    } }

    expect(flash[:alert]).to eq 'Não foi possível editar'
    expect(JobType.last.name).to eq 'Estágio'
    expect(JobType.last.status).to eq 'active'
  end

  it 'name must be unique' do
    admin = create(:user, role: :admin)
    create(:job_type, name: 'Estágio', status: :active)
    job_type = create(:job_type, name: 'Pleno', status: :active)

    login_as(admin)
    patch job_type_path(job_type.id), params: { job_type: {
      name: 'Estágio',
      status: :active
    } }

    expect(flash[:alert]).to eq 'Não foi possível editar'
    expect(JobType.last.name).to eq 'Pleno'
    expect(JobType.last.status).to eq 'active'
  end

  it 'job type is not registered' do
    admin = create(:user, role: :admin)

    login_as(admin)
    patch job_type_path(1), params: { job_type: {
      name: 'Estágio',
      status: :active
    } }

    expect(response).to redirect_to root_path
    expect(flash[:alert]).to eq 'Tipo de vaga não encontrado'
  end
end
