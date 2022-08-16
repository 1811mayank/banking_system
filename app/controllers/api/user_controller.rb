class   Api::UserController < Api::ApplicationController
    before_action :authenticate_user!
    
    protect_from_forgery with: :null_session
    def index 
        accounts = Account.all
        render json: accounts, status: 200
    end

    

    def details
        @user = current_user
        render json: {
            "user": @user,
            "accounts": @user.accounts
        }
    end

    def message_and_render(key,value)
        render json: {
            "#{key}": "#{value}"
        }
    end
end
