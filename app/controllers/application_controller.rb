class ApplicationController < ActionController::Base
  include SessionsHelper

  before_action :basic_authenticate
  before_action :authenticate_user!

  private
  def basic_authenticate
      authenticate_or_request_with_http_basic do |username, password|
        username == ENV["BASIC_AUTHEN"] && password == ENV["BASIC_AUTHEN_SECRET"]
     end
  end

  def authenticate_user!
    return if logged_in?
    render "shared/login", layout: false
  end

  def ensure_reviewer!
    return if current_user.reviewer?

    respond_to do |format|
      format.html{redirect_to root_path}
      format.js{head :forbidden}
      format.json{head :forbidden}
    end
  end
end
