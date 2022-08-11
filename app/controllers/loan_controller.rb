class   LoanController < ApplicationController
    before_action :check_signed_in?

    def new 
        @user = current_user 
        @flag = true
        if ((Time.now.to_date -  @user.dob.to_date).to_i/365) < 25
            @flag = false
        end
    end

    def create 
        @user = current_user 

        @deposite_amount = 0
        @user.accounts.each do |account|
            account.transactions.where(medium: "Deposit").each do |transaction| 
                @deposite_amount += transaction.amount
            end 
        end 

        if params[:duration].to_i < 2
            flash[:alert] = "Minimum duration to take loan is 2 year"
            redirect_to accounts_path

        elsif params[:amount].to_i < 500000
            flash[:alert] = "Minimum amount to take loan is 500000"
            redirect_to accounts_path

        elsif @deposite_amount < ((params[:amount].to_i)*(0.4))
            flash[:alert] = "Bank can only give 40% of total deposits as loan"
            redirect_to accounts_path

        else
            @interest = LoanType.find((params[:type_of_loan]).to_i).interest
            @deposite_amount_to_be_paid = (params[:amount].to_i)*((1 + ((@interest.to_i)/200.00))**(2*(params[:duration].to_i)))
            
            @account = Account.create(user_id: @user.id, type_of_account: "Loan", branch_id: 1,balance: @amount_to_be_paid, number: rand(1000000000 .. 9999999999))
            Loan.create(duration: params[:duration].to_i, loan_type_id: (params[:type_of_loan]).to_i,account_id: @account.id,amount:params[:amount].to_i )
            flash[:notice] = "Loan account has been created"
            redirect_to accounts_path
        end
    end

    def check_signed_in?
        unless user_signed_in?
            flash[:alert] = "Please sign in or sign up."
            redirect_to root_path
        end
    end
end