class   AccountsController < ApplicationController
    before_action :check_signed_in?
    def index 
        
    end

    def new
        @user = current_user
        @account = Account.new
    end

    def create 
        # byebug
        @user = current_user
        if ((params[:account][:type_of_account] == 'Saving' && params[:account][:balance].to_i < 10000) || (params[:account][:type_of_account] == 'Current' && params[:account][:balance].to_i < 100000))
            flash[:alert] = "Please deposit minimum amount to open account Saving/Current 10000/100000"
            redirect_to new_account_path
        
        elsif params[:account][:type_of_account] == 'Current' && ((Time.now.to_date -  User.last.dob.to_date).to_i/365) < 18
            flash[:alert] = "Minimum age for Current account is 18"
            redirect_to new_account_path
        else
            @account = Account.create(user_id: @user.id, type_of_account: params[:account][:type_of_account], branch_id: (params[:account][:branch_id]).to_i,balance: (params[:account][:balance]).to_f, number: rand(1000000000 .. 9999999999))
            Transaction.create(type_of_transaction: "Direct", medium: "Deposit",account_id: @account.id,amount: (params[:account][:balance]).to_f, where: (@account.number).to_s, remark: "Opening balance", balance: @account.balance)
            @atm = Atm.create(account_id: @account.id,expiry_date: DateTime.now.next_year(5).to_date,cvv: rand(100 .. 999),number: rand(1000000000000000 .. 9999999999999999))
            flash[:notice] = "Account has been created successfully. Your account number is #{@account.number}.\nYour atm details are 
            ATM number: #{@atm.number}, CVV: #{@atm.cvv}, Expiry date: #{@atm.expiry_date.strftime("%m/%Y")}"
            redirect_to accounts_path
        end
    end

    def transactions
        # byebug
        @accounts = current_user.accounts
        if current_user.admin 
            @accounts = User.find(params[:id]).accounts
        end
    end

    def deposit
        @accounts = current_user.accounts
    end

    def withdraw
        @accounts = current_user.accounts
    end

    def transfer
        @accounts = current_user.accounts
    end

    def atmwithdraw
        @account = Account.find(params[:id])
        @atm = @account.atm
    end

    def transaction
        @account = Account.find(params[:id])
        respond_to do |format|
            format.js { render partial: 'accounts/transaction-history' }
        end
    end

    def deposit_money
        @account = Account.find(params[:id])
        respond_to do |format|
            format.js { render partial: 'accounts/deposit-money' }
        end
    end

    def transfer_money
        @account = Account.find(params[:id])
        respond_to do |format|
            format.js { render partial: 'accounts/transfer-money' }
        end
    end

    def deposit_amount
        # byebug
        @account = Account.find(params[:id])
        if @account.type_of_account == "Loan"
            if params[:amount].to_f < (@account.loan.amount/10)
                
                if @account.balance - params[:amount].to_f < 0
                    flash[:alert] = "Amount to be paid is #{@account.balance}"
                    redirect_to accounts_path
                else
                    @account.balance = @account.balance - params[:amount].to_f
                    @account.save
                    Transaction.create(type_of_transaction: "Direct", medium: "Deposit",account_id: @account.id,amount: (params[:amount]).to_f, where: (@account.number).to_s, balance: @account.balance)
                    flash[:notice] = "You have successfully deposited your loan installment"
                    redirect_to accounts_path
                end
            else
                flash[:alert] = "You can't deposit more 10% of total loan amount"
                redirect_to accounts_path
            end
        else
            @account.balance = @account.balance + params[:amount].to_f
            @account.save
            Transaction.create(type_of_transaction: "Direct", medium: "Deposit",account_id: @account.id,amount: (params[:amount]).to_f, where: (@account.number).to_s,balance: @account.balance)
            flash[:notice] = "You have successfully deposited your money"
            redirect_to accounts_path
        end
    end

    def withdraw_money
        @account = Account.find(params[:id])
        respond_to do |format|
            format.js { render partial: 'accounts/withdraw-money' }
        end
    end

    def withdraw_amount
        byebug
        @account = Account.find(params[:id])
        @account.transaction do
            if @account.balance - params[:amount].to_f < 0
                flash[:alert] = "Insufficient Balance"
                redirect_to accounts_path
            else
                @account.balance = @account.balance - params[:amount].to_f
                @account.save
                Transaction.create(type_of_transaction: "Direct", medium: "Withdrawal",account_id: @account.id,amount: (params[:amount]).to_f, from: (@account.number).to_s, balance: @account.balance)
                
                flash[:notice] = "You have successfully withdraw your money"
                redirect_to accounts_path

            end
        end
    end

    def transfer_amount
        # byebug
        unless Account.find_by(number: (params[:number]).to_i)
            flash[:alert] = "Incorrect Account number"
            redirect_to accounts_path
        else
            @account = Account.find(params[:id])
            
            if @account.balance - params[:amount].to_f < 0
                flash[:alert] = "Insufficient Balance"
                redirect_to accounts_path
            else
                @account.balance = @account.balance - params[:amount].to_f
                @account.save
                Transaction.create(type_of_transaction: "Direct", medium: "Transfer",account_id: @account.id,amount: (params[:amount]).to_f, from: (@account.number).to_s, where: (params[:number]).to_s,balance: @account.balance)
                @account1 = Account.find_by(number: (params[:number]).to_i)
                @account1.balance = @account.balance + params[:amount].to_f
                @account1.save
                Transaction.create(type_of_transaction: "Direct", medium: "Credited",account_id: @account1.id,amount: (params[:amount]).to_f, from: (@account.number).to_s, where: (params[:number]).to_s,balance: @account.balance)
                flash[:notice] = "You have successfully withdraw your money"
                redirect_to accounts_path
            end
        end
    end

    def atmwithdraw_amount
        @account = Account.find(params[:id])
        @atm = @account.atm
        if params[:cvv].to_i != @atm.cvv
            flash[:alert] = "Incorrect CVV"
            redirect_to accounts_path
        elsif params[:expiry_date] != @atm.expiry_date.strftime("%m/%Y").to_s
            flash[:alert] = "Incorrect Expiry date"
            redirect_to accounts_path
        elsif params[:amount].to_i  > 20000
            flash[:alert] = "You can only withdraw money less then 20000"
            redirect_to accounts_path
        else
            
            if @account.balance - params[:amount].to_f < 0
                flash[:alert] = "Insufficient Balance"
                redirect_to accounts_path
            else
                @account.balance = @account.balance - params[:amount].to_f
                @account.save
                Transaction.create(type_of_transaction: "Indirect", medium: "Atm Withdrawal",account_id: @account.id,amount: (params[:amount]).to_f, from: (@account.number).to_s,balance: @account.balance)
                if @account.transactions.where(type_of_transaction: "Indirect").count > 5 && @account.type_of_account == "Saving"
                    @account.balance = @account.balance - 500.00
                    @account.save
                    Transaction.create(type_of_transaction: "Direct",account_id: @account.id,amount: (500).to_f, from: (@account.number).to_s, remark: "penalty charged",balance: @account.balance)
                end
                flash[:notice] = "You have successfully withdraw your money"
                redirect_to accounts_path
            end
        end
    end

    def details
        @user = current_user
        if current_user.admin 
            @user = User.find(params[:id])
        end
    end

    def balance
        @accounts = current_user.accounts
    end

    def confirm 
        @account = Account.new
        respond_to do |format|
            format.js { render partial: 'accounts/open_account' }
        end
    end

    def check_signed_in?
        unless user_signed_in?
            flash[:alert] = "Please sign in or sign up."
            redirect_to root_path
        end
    end
    
end