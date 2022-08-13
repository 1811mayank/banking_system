class Account < ApplicationRecord
    belongs_to :user
    belongs_to :branch
    has_many :transactions, dependent: :destroy
    has_one :atm, dependent: :destroy
    has_one :loan, dependent: :destroy
    
    validates_uniqueness_of :number
    validates :number,  numericality: true
    validates_length_of :number, :maximum => 10, :minimum => 10

    validates_with AccountValidator

end