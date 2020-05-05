require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  def authorization_params(user)
    { HTTP_AUTHORIZATION: ActionController::HttpAuthentication::Token.encode_credentials(user.api_key.access_token) }
  end
end
