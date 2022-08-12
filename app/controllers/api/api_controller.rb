class   Api::ApiController < Api::ApplicationController
    before_action :authenticate_user!
    
    def index 
        accounts = Account.all
        render json: accounts, status: 200
    end
    
end
