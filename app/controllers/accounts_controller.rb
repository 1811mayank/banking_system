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
            Transaction.create(type_of_transaction: "Direct", medium: "Deposit",account_id: @account.id,amount: (params[:account][:balance]).to_f, where: (@account.number).to_s, remark: "Opening balance", balance: @account.balance)
            @atm = Atm.create(account_id: @account.id,expiry_date: DateTime.now.next_year(5).to_date,cvv: rand(100 .. 999),number: rand(1000000000000000 .. 9999999999999999))
            message_and_redirect(:notice,"Account has been created successfully. Your account number is #{@account.number}.\nYour atm details are ATM number: #{@atm.number}, CVV: #{@atm.cvv}, Expiry date: #{@atm.expiry_date.strftime("%m/%Y")}")
        else
            message_and_redirect(:alert,"#{@account.errors.each{|error| p error}}")
        end
    end

    def confirm 
        respond_partial("open_account")
    end

    def balance
        
    end

    # direct withdrawal
    def withdraw
        
    end

    def withdraw_money
        respond_partial("withdraw-money")
    end

    def withdraw_amount
        @account.transaction do
            withdrawal_transaction
        end
    end

    # transfer money
    def transfer
        
    end

    def transfer_money
        respond_partial("transfer-money")
    end

    def transfer_amount
        unless Account.find_by(number: (params[:number]).to_i)
            message_and_redirect(:alert,"Incorrect Account number")
        else
            @account = Account.find(params[:id])
            @account.transaction do
                transfer_transaction
            end
        end
    end

    # atm withdrawal
    def atmwithdraw
        @atm = @account.atm
    end

    def atmwithdraw_amount
        @atm = @account.atm
        if params[:cvv].to_i != @atm.cvv
            message_and_redirect(:alert,"Incorrect CVV")

        elsif params[:expiry_date] != @atm.expiry_date.strftime("%m/%Y").to_s
            message_and_redirect(:alert,"Incorrect Expiry date")

        elsif params[:amount].to_i  > 20000
            message_and_redirect(:alert,"You can only withdraw money less then 20000")

        else
            @account.transaction do
                atm_transaction
            end
        end
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

    def transfer_transaction
        @account.balance = @account.balance - params[:amount].to_f
        if @account.save
            Transaction.create(type_of_transaction: "Direct", medium: "Transfer",account_id: @account.id,amount: (params[:amount]).to_f, from: (@account.number).to_s, where: (params[:number]).to_s,balance: @account.balance)
            @account1 = Account.find_by(number: (params[:number]).to_i)
            @account1.balance = @account.balance + params[:amount].to_f
            @account1.save
            Transaction.create(type_of_transaction: "Direct", medium: "Credited",account_id: @account1.id,amount: (params[:amount]).to_f, from: (@account.number).to_s, where: (params[:number]).to_s,balance: @account.balance)
            message_and_redirect(:notice,"You have successfully Transfered your money")
        else 
            message_and_redirect(:alert,"#{@account.errors.each{|error| p error}}")
        end
    end

    def atm_transaction
        @account.balance = @account.balance - params[:amount].to_f
        if @account.save
            Transaction.create(type_of_transaction: "Indirect", medium: "Atm Withdrawal",account_id: @account.id,amount: (params[:amount]).to_f, from: (@account.number).to_s,balance: @account.balance)
            if @account.transactions.where(type_of_transaction: "Indirect").count > 5 && @account.type_of_account == "Saving"
                @account.balance = @account.balance - 500.00
                @account.save
                Transaction.create(type_of_transaction: "Direct",account_id: @account.id,amount: (500).to_f, from: (@account.number).to_s, remark: "penalty charged",balance: @account.balance)
            end
            message_and_redirect(:notice,"You have successfully withdraw your money")
        else
            message_and_redirect(:alert,"#{@account.errors.each{|error| p error}}")
        end
    end

    def withdrawal_transaction
        @account.balance = @account.balance - params[:amount].to_f
        if @account.save
        Transaction.create(type_of_transaction: "Direct", medium: "Withdrawal",account_id: @account.id,amount: (params[:amount]).to_f, from: (@account.number).to_s, balance: @account.balance)
        message_and_redirect(:notice,"You have successfully withdraw your money")
        else 
            message_and_redirect(:alert,"#{@account.errors.each{|error| p error}}")
        end   
    end

    
end