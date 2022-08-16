class   AccountsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_up_accounts_variable, only: [:transfer, :withdraw,:balance]
    before_action :set_up_account_variable, only: [:atmwithdraw,:transfer_money,:withdraw_money,:withdraw_amount,:atmwithdraw_amount]
    before_action :set_up_user_variable, only: [:new,:create]
    before_action :set_up_new_account_variable, only: [:new,:confirm]
    
    def index 

    end

    def new
        
    end

    def create 
        @account = Account.new(user_id: @user.id, type_of_account: params[:account][:type_of_account], branch_id: (params[:account][:branch_id]).to_i,balance: (params[:account][:balance]).to_f, number: rand(1000000000 .. 9999999999))
        if @account.save
            message_and_redirect(:notice,"Account has been created successfully")
        else
            message_and_redirect(:alert,"#{@account.errors.each{|error| p error}}")
        end
    end

    def confirm 
        respond_partial("open_account")
    end

    def balance
        
    end

    


    private

    def set_up_accounts_variable 
        @accounts = current_user.accounts
    end

    def set_up_account_variable
        @account = Account.find(params[:id])
    end

    def set_up_user_variable
        @user = current_user
    end

    def set_up_new_account_variable
        @account = Account.new
    end

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