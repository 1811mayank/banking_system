class   Api::TransactionsController < Api::ApplicationController
    before_action :authenticate_user!
    
    protect_from_forgery with: :null_session

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

    def message_and_render(key,value)
        render json: {
            "#{key}": "#{value}"
        }
    end

end