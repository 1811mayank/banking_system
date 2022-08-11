class   AccountsController < ApplicationController
    before_action :check_signed_in?
    before_action :set_up_accounts_variable, only: [:transactions, :deposit, :transfer, :withdraw,:balance]
    before_action :set_up_account_variable, only: [:atmwithdraw,:transaction,:deposit_money,:transfer_money,:withdraw_money,:deposit_amount,:withdraw_amount,:atmwithdraw_amount]
    before_action :set_up_user_variable, only: [:new,:details,:create]
    before_action :set_up_new_account_variable, only: [:new,:confirm]
    
    def index 

    end

    def new
        
    end

    def deposit
        
    end

    def withdraw
        
    end

    def transfer
        
    end

    def balance
        
    end

    def transaction
        respond_partial("transaction-history")
    end

    def deposit_money
        respond_partial("deposit-money")
    end

    def transfer_money
        respond_partial("transfer-money")
    end

    def confirm 
        respond_partial("open_account")
    end

    def withdraw_money
        respond_partial("withdraw-money")
    end

    def details
        if current_user.admin 
            @user = User.find(params[:id])
        end
    end

    def transactions
        if current_user.admin 
            @accounts = User.find(params[:id]).accounts
        end
    end

    def atmwithdraw
        @atm = @account.atm
    end

    def create 
        if ((params[:account][:type_of_account] == 'Saving' && params[:account][:balance].to_i < 10000) || (params[:account][:type_of_account] == 'Current' && params[:account][:balance].to_i < 100000))
            message_and_redirect(:alert,"Please deposit minimum amount to open account Saving/Current 10000/100000")
        
        elsif params[:account][:type_of_account] == 'Current' && ((Time.now.to_date -  User.last.dob.to_date).to_i/365) < 18
            message_and_redirect(:alert,"Minimum age for Current account is 18")
        
        else
            @account = Account.create(user_id: @user.id, type_of_account: params[:account][:type_of_account], branch_id: (params[:account][:branch_id]).to_i,balance: (params[:account][:balance]).to_f, number: rand(1000000000 .. 9999999999))
            Transaction.create(type_of_transaction: "Direct", medium: "Deposit",account_id: @account.id,amount: (params[:account][:balance]).to_f, where: (@account.number).to_s, remark: "Opening balance", balance: @account.balance)
            @atm = Atm.create(account_id: @account.id,expiry_date: DateTime.now.next_year(5).to_date,cvv: rand(100 .. 999),number: rand(1000000000000000 .. 9999999999999999))
            message_and_redirect(:notice,"Account has been created successfully. Your account number is #{@account.number}.\nYour atm details are ATM number: #{@atm.number}, CVV: #{@atm.cvv}, Expiry date: #{@atm.expiry_date.strftime("%m/%Y")}")
        end
    end

    def deposit_amount
        if @account.type_of_account == "Loan"
            if params[:amount].to_f < (@account.loan.amount/10)
                if @account.balance - params[:amount].to_f < 0
                    message_and_redirect(:alert,"Amount to be paid is #{@account.balance}")

                else
                    @account.balance = @account.balance - params[:amount].to_f
                    @account.save
                    Transaction.create(type_of_transaction: "Direct", medium: "Deposit",account_id: @account.id,amount: (params[:amount]).to_f, where: (@account.number).to_s, balance: @account.balance)
                    message_and_redirect(:notice,"You have successfully deposited your loan installment")
                end

            else
                message_and_redirect(:alert,"You can't deposit more 10% of total loan amount")
            end
        else
            if condition_for_invalid_amount
                message_and_redirect(:alert,"deposit amount invalid")

            else
                @account.balance = @account.balance + params[:amount].to_f
                @account.save
                Transaction.create(type_of_transaction: "Direct", medium: "Deposit",account_id: @account.id,amount: (params[:amount]).to_f, where: (@account.number).to_s,balance: @account.balance)
                message_and_redirect(:notice,"You have successfully deposited your money")
            end
        end
    end

    def withdraw_amount
        # byebug
        @account.transaction do
            if condition_for_insufficient_balance
                message_and_redirect(:alert,"Insufficient balance")

            elsif condition_for_invalid_amount
                message_and_redirect(:alert,"deposit amount invalid")

            else
                @account.balance = @account.balance - params[:amount].to_f
                @account.save
                Transaction.create(type_of_transaction: "Direct", medium: "Withdrawal",account_id: @account.id,amount: (params[:amount]).to_f, from: (@account.number).to_s, balance: @account.balance)
                message_and_redirect(:notice,"You have successfully withdraw your money")
            end
        end
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
                if condition_for_insufficient_balance
                    message_and_redirect(:alert,"Insufficient balance")

                elsif condition_for_invalid_amount
                    message_and_redirect(:alert,"deposit amount invalid")

                else
                    @account.balance = @account.balance - params[:amount].to_f
                    @account.save
                    Transaction.create(type_of_transaction: "Indirect", medium: "Atm Withdrawal",account_id: @account.id,amount: (params[:amount]).to_f, from: (@account.number).to_s,balance: @account.balance)
                    if @account.transactions.where(type_of_transaction: "Indirect").count > 5 && @account.type_of_account == "Saving"
                        @account.balance = @account.balance - 500.00
                        @account.save
                        Transaction.create(type_of_transaction: "Direct",account_id: @account.id,amount: (500).to_f, from: (@account.number).to_s, remark: "penalty charged",balance: @account.balance)
                    end
                    message_and_redirect(:notice,"You have successfully withdraw your money")
                end
            end
        end
    end

    def transfer_amount
        unless Account.find_by(number: (params[:number]).to_i)
            message_and_redirect(:alert,"Incorrect Account number")

        else
            @account = Account.find(params[:id])
            @account.transaction do
                if condition_for_insufficient_balance
                    message_and_redirect(:alert,"Insufficient balance")

                elsif condition_for_invalid_amount
                    message_and_redirect(:alert,"deposit amount invalid")
                    
                else
                    @account.balance = @account.balance - params[:amount].to_f
                    @account.save
                    Transaction.create(type_of_transaction: "Direct", medium: "Transfer",account_id: @account.id,amount: (params[:amount]).to_f, from: (@account.number).to_s, where: (params[:number]).to_s,balance: @account.balance)
                    @account1 = Account.find_by(number: (params[:number]).to_i)
                    @account1.balance = @account.balance + params[:amount].to_f
                    @account1.save
                    Transaction.create(type_of_transaction: "Direct", medium: "Credited",account_id: @account1.id,amount: (params[:amount]).to_f, from: (@account.number).to_s, where: (params[:number]).to_s,balance: @account.balance)
                    message_and_redirect(:notice,"You have successfully Transfered your money")
                end
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

    def condition_for_insufficient_balance
        (@account.balance - params[:amount].to_f) < 0 
    end

    def condition_for_invalid_amount
        params[:amount].to_f < 1
    end

    def message_and_redirect(key,value)
        flash[key] = value
        redirect_to accounts_path
    end

    def check_signed_in?
        unless user_signed_in?
            flash[:alert] = "Please sign in or sign up."
            redirect_to root_path
        end
    end
    
end