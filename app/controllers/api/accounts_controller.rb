class   Api::AccountsController < Api::ApplicationController
    before_action :authenticate_user!
    
    protect_from_forgery with: :null_session

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

    def balance
        @accounts = current_user.accounts
        render json: {
            "Accounts": @accounts
        }
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

    def message_and_render(key,value)
        render json: {
            "#{key}": "#{value}"
        }
    end
end