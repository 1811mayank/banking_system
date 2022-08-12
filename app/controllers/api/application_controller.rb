class Api::ApplicationController < ActionController::Base
    include DeviseTokenAuth::Concerns::SetUserByToken
    before_action :authenticate_user!
    skip_before_action :verify_authenticity_token
    protect_from_forgery with: :null_session
end
