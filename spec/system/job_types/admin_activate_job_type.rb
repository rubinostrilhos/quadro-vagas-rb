require 'rails_helper'
include ActionView::RecordIdentifier

describe 'Admin activates job type', type: :system do
  it 'in the job types index page' do
    admin = create(:user, role: :admin)
    job_type = create(:job_type, status: :archived)

    login_as admin
    visit job_types_path

    within "##{dom_id job_type}" do
      expect(page).to have_button 'Ativar'
    end
  end

  it 'and an active job type does not have an activate button' do
    admin = create(:user, role: :admin)
    job_type = create(:job_type, status: :active)

    login_as admin
    visit job_types_path

    within "##{dom_id job_type}" do
      expect(page).not_to have_button 'Ativar'
    end
  end

  it 'success' do
    admin = create(:user, role: :admin)
    job_type = create(:job_type, status: :archived)

    login_as admin
    visit job_types_path
    within "##{dom_id job_type}" do
      click_on 'Ativar'
    end

    expect(current_path).to eq job_types_path
    expect(page).to have_content 'Tipo de vaga ativada'
    within "##{dom_id job_type}" do
      expect(page).not_to have_content 'Arquivado'
      expect(page).not_to have_button 'Ativar'
      expect(page).to have_content 'Ativo'
    end
  end
end
