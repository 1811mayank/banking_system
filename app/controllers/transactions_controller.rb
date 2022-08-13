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

    
    def deposit
        @accounts = current_user.accounts
    end

    def deposit_money
        @account = Account.find(params[:id])
        respond_partial("deposit-money")
    end

    def deposit_amount
        @account = Account.find(params[:id])
        if @account.type_of_account == "Loan"
            loan_deposit
        else
            direct_transaction
        end
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

    def direct_transaction 
        @account.balance = @account.balance + params[:amount].to_f
        if @account.save
            Transaction.create(type_of_transaction: "Direct", medium: "Deposit",account_id: @account.id,amount: (params[:amount]).to_f, where: (@account.number).to_s,balance: @account.balance)
            message_and_redirect(:notice,"You have successfully deposited your money") 
        else
            message_and_redirect(:alert,"#{@account.errors.each{|error| p error}}")
        end
    end

    def loan_deposit
        @account.balance = @account.balance - params[:amount].to_f
        if @account.save
            Transaction.create(type_of_transaction: "Direct", medium: "Deposit",account_id: @account.id,amount: (params[:amount]).to_f, where: (@account.number).to_s, balance: @account.balance)
            message_and_redirect(:notice,"You have successfully deposited your loan installment")
        else 
            message_and_redirect(:alert,"#{@account.errors.each{|error| p error}}")
        end
    end


    
end