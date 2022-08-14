require 'test_helper'

class LoanTest < ActiveSupport::TestCase
    
    def setup
        @user = User.create(email:"m@m.com",password: "123456",dob: "18/05/1959")
        @branch = Branch.create(name:"12321")
        @account = Account.create(type_of_account: "Loan",balance: 6000000,user_id: @user.id, number: 2236758213, branch_id: @branch.id) 
        @type = LoanType.create(name: "Home", interest: 7)
    end

    test "duration of Loan should be more then 2 year" do
        @loan = Loan.new(account_id: @account.id, duration: 1, amount: 6000000, loan_type_id: @type.id)
        assert_not @loan.valid?
    end

    test "amount of Loan should be more then 500000" do
        @loan = Loan.new(account_id: @account.id, duration: 1, amount: 6000000, loan_type_id: @type.id)
        assert_not @loan.valid?
    end

end