class   Api::UserController < Api::ApplicationController
    before_action :authenticate_user!
    
    protect_from_forgery with: :null_session
    def index 
        accounts = Account.all
        render json: accounts, status: 200
    end

    def create 
        @user = current_user
        @account = Account.new(user_id: @user.id, type_of_account: params[:account][:type_of_account], branch_id: (params[:account][:branch_id]).to_i,balance: (params[:account][:balance]).to_f, number: rand(1000000000 .. 9999999999))
        if @account.save
            render json: {
                "notice": "Account has been created successfully."
            }
        else
            render json: {
                "alert": "error ocuured"
            }
        end
    end

    def details
        @user = current_user
        render json: {
            "user": @user,
            "accounts": @user.accounts
        }
    end

    def balance
        @accounts = current_user.accounts
        render json: {
            "Accounts": @accounts
        }
    end

    def transactions
        @accounts = current_user.accounts
        render json: @accounts.to_json(include: [:transactions])
    end

    def deposit
        @account = Account.find_by(params[:number])

        if @account.type_of_account == "Loan"
            @account.balance = @account.balance - params[:amount].to_f
            if @account.save
                Transaction.create(type_of_transaction: "Direct", medium: "Deposit",account_id: @account.id,amount: (params[:amount]).to_f, where: (@account.number).to_s, balance: @account.balance)
                message_and_render("notice","You have successfully deposited your loan installment")
            else 
                message_and_render("alert", "error ocuured")    
            end
        else
            @account.balance = @account.balance + params[:amount].to_f
            if @account.save
                Transaction.create(type_of_transaction: "Direct", medium: "Deposit",account_id: @account.id,amount: (params[:amount]).to_f, where: (@account.number).to_s,balance: @account.balance)
                message_and_render("notice","You have successfully deposited your money")
            else
                message_and_render("alert", "error ocuured")
            end
        end
    end

    def withdraw
        @account = Account.find_by(params[:number])
        @account.transaction do
            @account.balance = @account.balance - params[:amount].to_f
            if @account.save
                Transaction.create(type_of_transaction: "Direct", medium: "Withdrawal",account_id: @account.id,amount: (params[:amount]).to_f, from: (@account.number).to_s, balance: @account.balance)
                message_and_render("notice","You have successfully withdraw your money")
            else 
                message_and_render("alert", "error ocuured")
            end
        end
    end

    def atmwithdraw
        @account = Atm.find_by(number: params[:number].to_i).account
        @atm = Atm.find_by(number: params[:number].to_i)
        if @account == nil
            message_and_render("alert","Atm number is wrong")

        elsif params[:cvv].to_i != @atm.cvv
            message_and_render("alert","Incorrect CVV")

        elsif params[:expiry_date] != @atm.expiry_date.strftime("%m/%Y").to_s
            message_and_render("alert","Incorrect Expiry date")

        elsif params[:amount].to_i  > 20000
            message_and_render("alert","You can only withdraw money less then 20000")

        else
            @account.transaction do
                
                @account.balance = @account.balance - params[:amount].to_f
                if @account.save
                    Transaction.create(type_of_transaction: "Indirect", medium: "Atm Withdrawal",account_id: @account.id,amount: (params[:amount]).to_f, from: (@account.number).to_s,balance: @account.balance)
                    if @account.transactions.where(type_of_transaction: "Indirect").count > 5 && @account.type_of_account == "Saving"
                        @account.balance = @account.balance - 500.00
                        @account.save
                        Transaction.create(type_of_transaction: "Direct",account_id: @account.id,amount: (500).to_f, from: (@account.number).to_s, remark: "penalty charged",balance: @account.balance)
                    end
                    message_and_render("notice","You have successfully withdraw your money")
                else 
                    message_and_render("alert", "error ocuured") 
                end
            end
        end
    end

    def transfer
        unless Account.find_by(number: (params[:to]).to_i)
            message_and_render("alert","Incorrect Account number")
        else
            @account = Account.find_by(params[:from])
            @account.transaction do
                
                @account.balance = @account.balance - params[:amount].to_f
                if @account.save
                    Transaction.create(type_of_transaction: "Direct", medium: "Transfer",account_id: @account.id,amount: (params[:amount]).to_f, from: (@account.number).to_s, where: (params[:to]).to_s,balance: @account.balance)
                    @account1 = Account.find_by(number: (params[:to]).to_i)
                    @account1.balance = @account.balance + params[:amount].to_f
                    @account1.save
                    Transaction.create(type_of_transaction: "Direct", medium: "Credited",account_id: @account1.id,amount: (params[:amount]).to_f, from: (@account.number).to_s, where: (params[:to]).to_s,balance: @account.balance)
                    message_and_render("notice","You have successfully Transfered your money")
                else 
                    message_and_render("alert", "error ocuured")
                end
            end
        end
    end

    def loan 
        @user = current_user 
        @interest = LoanType.find_by(name: params[:type_of_loan]).interest
            @deposite_amount_to_be_paid = (params[:amount].to_i)*((1 + ((@interest.to_i)/200.00))**(2*(params[:duration].to_i)))
            @account = Account.create(user_id: @user.id, type_of_account: "Loan", branch_id: 1,balance: @amount_to_be_paid, number: rand(1000000000 .. 9999999999))
            Loan.create(duration: params[:duration].to_i, loan_type_id: (params[:type_of_loan]).to_i,account_id: @account.id,amount:params[:amount].to_i )
            message_and_render("Notice","Loan account has been created")
    end

    def message_and_render(key,value)
        render json: {
            "#{key}": "#{value}"
        }
    end
end
