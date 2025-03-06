require "application_system_test_case"

class WelcomeMessageTest < ApplicationSystemTestCase
  test "Vê o hello world após 3 segundos" do
    visit root_url
    sleep 3
    assert_text "Hello, World!"
  end
end
