class ApiController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods

  def current_user
    @current_user
  end

  protected

  def authenticate
    authenticate_or_request_with_http_token do |token, options|
      key = ApiKey.where(access_token: token).first
      @current_user = key&.user
    end
  end

end
