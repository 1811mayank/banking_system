require 'test_helper'

class AtmTest < ActiveSupport::TestCase
    
    def setup
        @user = User.create(email:"m@m.com",password: "123456",dob: "18/05/1959")
        @branch = Branch.create(name:"12321")
        @account = Account.create(type_of_account: "Saving",balance: 6000000,user_id: @user.id, number: 2236758213, branch_id: @branch.id) 
        
    end

    test "Atm number should be of 16 digits" do
        @atm = Atm.new(number:1234, cvv: 123, expiry_date: "17/06/2027", account_id: @account.id)
        assert_not @atm.valid?
    end

    test "Atm cvv should be of 3 digits" do
        @atm = Atm.new(number:1234565432123456, cvv: 13, expiry_date: "17/06/2027", account_id: @account.id)
        assert_not @atm.valid?
    end

    test "Atm number uniqueness" do
        @atm = Atm.create(number:1234565432123456, cvv: 123, expiry_date: "17/06/2027", account_id: @account.id)
        @atm1 = Atm.new(number:1234565432123456, cvv: 137, expiry_date: "17/06/2027", account_id: @account.id)
        assert_not @atm1.valid?
    end

end