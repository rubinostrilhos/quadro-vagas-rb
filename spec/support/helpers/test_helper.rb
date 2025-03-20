module TestHelper
  def login_as(user)
    Current.session = user.sessions.create!
    request = ActionDispatch::Request.new(Rails.application.env_config)
    cookies = request.cookie_jar
    cookies.signed[:session_id] = { value: Current.session.id, httponly: true, same_site: :lax }
  end
end
