class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end
class AccountValidator < ActiveModel::Validator
  def validate(account)
      if ((account.type_of_account == "Saving" && account.balance < 10000) || (account.type_of_account == "Current" && account.balance < 100000))
        account.errors.add :base, "Please deposit minimum amount to open account Saving/Current 10000/100000"
      end
      if account.type_of_account == 'Current' && ((Time.now.to_date -  account.user.dob.to_date).to_i/365) < 18
        account.errors.add :base, "Minimum age for Current account is 18"
      end
      if account.type_of_account == 'Loan' && ((Time.now.to_date -  account.user.dob.to_date).to_i/365) < 25
        account.errors.add :base, "Minimum age for Current account is 18"
      end
      if account.balance < 0
        account.errors.add :base, "Insufficient balance"
      end
  end
end
 
class LoanValidator < ActiveModel::Validator
  def validate(loan)
    if (loan.duration) < 3
      loan.errors.add :base, "Minimum duration to take loan is 2 year"
    end
    if (loan.amount) < 500000.00
      loan.errors.add :base, "Minimum amount to take loan is 500000"
    end
  end
end