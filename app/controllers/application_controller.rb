class ApplicationController < ActionController::Base
    before_action :configure_permitted_parameters, if: :devise_controller?

    protected

    def configure_permitted_parameters
        devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name, :city, :dob])
        # devise_parameter_sanitizer.permit(:sign_in) { |u| u.permit(:id, :password, :remember_me) }
    end
end
