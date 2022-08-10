class Branch < ApplicationRecord
    has_many :accounts, dependent: :destroy
    
end