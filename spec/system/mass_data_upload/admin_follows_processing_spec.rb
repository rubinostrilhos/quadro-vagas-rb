require 'rails_helper'

describe 'Admin uploads file', type: :system do

  it 'and sees its conclusion', js: true do
    user = create(:user, role: :admin)
    login_as user

    visit processing_path

    file_path = Rails.root.join('spec', 'support', 'files', 'test_file.csv')
    ProcessFileJob.perform_now(file_path.to_s)

    expect(page).to have_content("Processamento concluído!")
    expect(page).to have_content("Registros criados com sucesso: 3")
    expect(page).to have_content("Erros: 0")
  end

  it 'and sees some fails', js: true do
    user = create(:user, role: :admin)
    login_as user

    visit processing_path

    file_path = Rails.root.join('spec', 'support', 'files', 'bad_input_test_file.csv')
    ProcessFileJob.perform_now(file_path.to_s)

    expect(page).to have_content("Processamento concluído!")
    expect(page).to have_content("Registros criados com sucesso: 3")
    expect(page).to have_content("Erros: 3")
  end
end
