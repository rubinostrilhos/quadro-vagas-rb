require 'rails_helper'
include ActionView::RecordIdentifier

describe 'Admin archives job type', type: :system do
  it 'in the job types index page' do
    admin = create(:user, role: :admin)
    job_type = create(:job_type, status: :active)

    login_as admin
    visit job_types_path

    within "##{dom_id job_type}" do
      expect(page).to have_button 'Arquivar'
    end
  end

  it 'and an archived job type does not have an archive button' do
    admin = create(:user, role: :admin)
    job_type = create(:job_type, status: :archived)

    login_as admin
    visit job_types_path

    within "##{dom_id job_type}" do
      expect(page).not_to have_button 'Arquivar'
    end
  end

  it 'success' do
    admin = create(:user, role: :admin)
    job_type = create(:job_type, status: :active)

    login_as admin
    visit job_types_path
    within "##{dom_id job_type}" do
      click_on 'Arquivar'
    end

    expect(current_path).to eq job_types_path
    expect(page).to have_content 'Tipo de vaga arquivada'
    within "##{dom_id job_type}" do
      expect(page).not_to have_content 'Ativo'
      expect(page).not_to have_button 'Arquivar'
      expect(page).to have_content 'Arquivado'
    end
  end
end
