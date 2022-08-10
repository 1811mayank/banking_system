class DashboardController < ApplicationController
    def index
        @users = User.where(admin: false)
    end
    def search
        if params[:user].present?
          @users = User.search(params[:user])
           
           if @users
            respond_to do |format|
              format.js { render partial: 'dashboard/user_result' }
            end
          else
            respond_to do |format|
              flash.now[:alert] = "Couldn't find user"
              format.js { render partial: 'dashboard/user_result' }
            end
          end    
        else
          respond_to do |format|
            flash.now[:alert] = "Please enter a user name or email to search"
            format.js { render partial: 'dashboard/user_result' }
          end
        end
    
      end
end