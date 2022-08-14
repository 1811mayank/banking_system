require 'test_helper'

class AccountTest < ActiveSupport::TestCase

  def setup
    @user = User.create(email:"m@m.com",password: "123456",dob: "18/05/1999")
    @branch = Branch.create(name:"12321")
  end

  test "account should be valid" do
    @account = Account.new(type_of_account: "Saving",balance: 1341234,user_id: @user.id, number: 2232139874, branch_id: @branch.id) 
    assert @account.valid?
  end

  test "Saving account opening balance should be more than 10000" do
    @account = Account.new(type_of_account: "Saving",balance: 1341,user_id: @user.id, number: 2232139874, branch_id: @branch.id) 
    assert_not @account.valid?
  end

  test "Current account opening balance should be more than 100000" do
    @account = Account.new(type_of_account: "Current",balance: 1000,user_id: @user.id, number: 2232139874, branch_id: @branch.id) 
    assert_not @account.valid?
  end

  test "Age to open current account is more then 18" do
    @user.dob = "18/03/2020"
    @user.save
    @account = Account.new(type_of_account: "Current",balance: 1000000,user_id: @user.id, number: 2232139874, branch_id: @branch.id) 
    assert_not @account.valid?
  end

  test "Age test for Loan account opening" do
    @user.dob = "18/05/1999"
    @user.save
    @account = Account.create(type_of_account: "Loan",balance: 6000000,user_id: @user.id, number: 2236758213, branch_id: @branch.id) 
    assert_not @account.valid?
  end
  
  test "Account number uniqueness" do
    @account = Account.create(type_of_account: "Saving",balance: 6000000,user_id: @user.id, number: 2236758213, branch_id: @branch.id) 
    @account1 = Account.new(type_of_account: "Saving",balance: 6000000,user_id: @user.id, number: 2236758213, branch_id: @branch.id)
    assert_not @account1.valid?
  end

  test "Account number should be length of 10" do
    @account = Account.create(type_of_account: "Saving",balance: 6000000,user_id: @user.id, number: 223675821, branch_id: @branch.id) 
    assert_not @account.valid?
  end

end
