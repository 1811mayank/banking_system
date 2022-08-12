class   Api::ApiController < Api::ApplicationController
    before_action :authenticate_user!
    
    protect_from_forgery with: :null_session
    def index 
        accounts = Account.all
        render json: accounts, status: 200
    end

    def create 
        @user = current_user
        if ((params[:account][:type_of_account] == 'Saving' && params[:account][:balance].to_i < 10000) || (params[:account][:type_of_account] == 'Current' && params[:account][:balance].to_i < 100000))
            message_and_render("alert","Please deposit minimum amount to open account Saving/Current 10000/100000")
        
        elsif params[:account][:type_of_account] == 'Current' && ((Time.now.to_date -  current_user.dob.to_date).to_i/365) < 18
            
            render json: {
                "alert": "Minimum age for Current account is 18"
            }, status: 200
        else
            @account = Account.create(user_id: @user.id, type_of_account: params[:account][:type_of_account], branch_id: (params[:account][:branch_id]).to_i,balance: (params[:account][:balance]).to_f, number: rand(1000000000 .. 9999999999))
            Transaction.create(type_of_transaction: "Direct", medium: "Deposit",account_id: @account.id,amount: (params[:account][:balance]).to_f, where: (@account.number).to_s, remark: "Opening balance", balance: @account.balance)
            @atm = Atm.create(account_id: @account.id,expiry_date: DateTime.now.next_year(5).to_date,cvv: rand(100 .. 999),number: rand(1000000000000000 .. 9999999999999999))
            render json: {
                "notice": "Account has been created successfully. Your account number is #{@account.number}.\nYour atm details are ATM number: #{@atm.number}, CVV: #{@atm.cvv}, Expiry date: #{@atm.expiry_date.strftime("%m/%Y")}"
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
            if params[:amount].to_f < (@account.loan.amount/10)
                if @account.balance - params[:amount].to_f < 0
                    message_and_render("alert","Amount to be paid is #{@account.balance}")

                else
                    @account.balance = @account.balance - params[:amount].to_f
                    @account.save
                    Transaction.create(type_of_transaction: "Direct", medium: "Deposit",account_id: @account.id,amount: (params[:amount]).to_f, where: (@account.number).to_s, balance: @account.balance)
                    message_and_render("notice","You have successfully deposited your loan installment")
                end

            else
                message_and_render("alert","You can't deposit more 10% of total loan amount")
            end
        else
            if params[:amount].to_f < 1
                message_and_render("alert","deposit amount invalid")

            else
                @account.balance = @account.balance + params[:amount].to_f
                @account.save
                Transaction.create(type_of_transaction: "Direct", medium: "Deposit",account_id: @account.id,amount: (params[:amount]).to_f, where: (@account.number).to_s,balance: @account.balance)
                message_and_render("notice","You have successfully deposited your money")
            end
        end
    end

    def withdraw
        @account = Account.find_by(params[:number])
        @account.transaction do
            if (@account.balance - params[:amount].to_f) < 0 
                message_and_render("alert","Insufficient balance")

            elsif params[:amount].to_f < 1
                message_and_render("alert","deposit amount invalid")
            else
                @account.balance = @account.balance - params[:amount].to_f
                @account.save
                Transaction.create(type_of_transaction: "Direct", medium: "Withdrawal",account_id: @account.id,amount: (params[:amount]).to_f, from: (@account.number).to_s, balance: @account.balance)
                message_and_render("notice","You have successfully withdraw your money")
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
                if (@account.balance - params[:amount].to_f) < 0 
                    message_and_render("alert","Insufficient balance")

                elsif params[:amount].to_f < 1
                    message_and_render("alert","deposit amount invalid")

                else
                    @account.balance = @account.balance - params[:amount].to_f
                    @account.save
                    Transaction.create(type_of_transaction: "Indirect", medium: "Atm Withdrawal",account_id: @account.id,amount: (params[:amount]).to_f, from: (@account.number).to_s,balance: @account.balance)
                    if @account.transactions.where(type_of_transaction: "Indirect").count > 5 && @account.type_of_account == "Saving"
                        @account.balance = @account.balance - 500.00
                        @account.save
                        Transaction.create(type_of_transaction: "Direct",account_id: @account.id,amount: (500).to_f, from: (@account.number).to_s, remark: "penalty charged",balance: @account.balance)
                    end
                    message_and_render("notice","You have successfully withdraw your money")
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
                if (@account.balance - params[:amount].to_f) < 0 
                    message_and_render("alert","Insufficient balance")

                elsif params[:amount].to_f < 1
                    message_and_render("alert","deposit amount invalid")
                    
                else
                    @account.balance = @account.balance - params[:amount].to_f
                    @account.save
                    Transaction.create(type_of_transaction: "Direct", medium: "Transfer",account_id: @account.id,amount: (params[:amount]).to_f, from: (@account.number).to_s, where: (params[:to]).to_s,balance: @account.balance)
                    @account1 = Account.find_by(number: (params[:to]).to_i)
                    @account1.balance = @account.balance + params[:amount].to_f
                    @account1.save
                    Transaction.create(type_of_transaction: "Direct", medium: "Credited",account_id: @account1.id,amount: (params[:amount]).to_f, from: (@account.number).to_s, where: (params[:to]).to_s,balance: @account.balance)
                    message_and_render("notice","You have successfully Transfered your money")
                end
            end
        end
    end

    def loan 
            @user = current_user 
            @deposite_amount = 0
            @user.accounts.each do |account|
                account.transactions.where(medium: "Deposit").each do |transaction| 
                    @deposite_amount += transaction.amount
                end 
            end 
            if ((Time.now.to_date -  @user.dob.to_date).to_i/365) < 25
                message_and_render("alert","Minimum age to take a loan is 25")
            
            elsif params[:duration].to_i < 2
                message_and_render("alert","Minimum duration to take loan is 2 year")
    
            elsif params[:amount].to_i < 500000
                message_and_render("alert","Minimum amount to take loan is 500000")
    
            elsif @deposite_amount < ((params[:amount].to_i)*(0.4))
                message_and_render("alert","Bank can only give 40% of total deposits as loan")
            else
                @interest = LoanType.find_by(name: params[:type_of_loan]).interest
                @deposite_amount_to_be_paid = (params[:amount].to_i)*((1 + ((@interest.to_i)/200.00))**(2*(params[:duration].to_i)))
                
                @account = Account.create(user_id: @user.id, type_of_account: "Loan", branch_id: 1,balance: @amount_to_be_paid, number: rand(1000000000 .. 9999999999))
                Loan.create(duration: params[:duration].to_i, loan_type_id: (params[:type_of_loan]).to_i,account_id: @account.id,amount:params[:amount].to_i )
                message_and_render("Notice","Loan account has been created")
            end
      
    end

    def message_and_render(key,value)
        render json: {
            "#{key}": "#{value}"
        }
    end
end
