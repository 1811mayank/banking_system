class Atm < ApplicationRecord
    belongs_to :account
    validates :number, :cvv, numericality: true
    validates_uniqueness_of :number
    validates_length_of :cvv, :maximum => 3, :minimum => 3
    validates_length_of :number, :maximum => 16, :minimum => 16
end