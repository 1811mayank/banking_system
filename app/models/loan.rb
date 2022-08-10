class Loan < ApplicationRecord
    belongs_to :account
    belongs_to :loan_type
end