class   Api::LoanController < Api::ApplicationController
    before_action :authenticate_user!
    
    protect_from_forgery with: :null_session

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