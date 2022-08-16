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
    after_create :transaction_atm

    def transaction_atm
        account = Account.last
        Transaction.create(type_of_transaction: "Direct", medium: "Deposit",account_id: account.id,amount: account.balance, where: (account.number).to_s, remark: "Opening balance", balance: account.balance)
        Atm.create(account_id: account.id,expiry_date: DateTime.now.next_year(5).to_date,cvv: rand(100 .. 999),number: rand(1000000000000000 .. 9999999999999999))
    end

end