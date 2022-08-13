class   UsersController < ApplicationController
    before_action :authenticate_user!
    def show
        @user = current_user
        if current_user.admin 
            @user = User.find(params[:id])
        end
    end
    
end