class   TransactionsController < ApplicationController
    before_action :authenticate_user!
    def index
        @accounts = current_user.accounts
        if current_user.admin 
            @accounts = User.find(params[:id]).accounts
        end
    end

    def show
        @account = Account.find(params[:id])
        respond_partial("transaction-history")
    end

    private
    
    def respond_partial(name)
        respond_to do |format|
            format.js { render partial: "layouts/#{name}" }
        end
    end

    def message_and_redirect(key,value)
        flash[key] = value
        redirect_to accounts_path
    end


    
end