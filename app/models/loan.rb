class Loan < ApplicationRecord
    belongs_to :account
    belongs_to :loan_type
    validates_with LoanValidator
end