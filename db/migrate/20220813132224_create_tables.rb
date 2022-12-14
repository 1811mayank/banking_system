class CreateTables < ActiveRecord::Migration[6.0]
  def change
    create_table :branches do |t|
      t.string :name
      t.string :city
      t.timestamps null: false
    end
  
  
    create_table :transactions do |t|
      t.string :type_of_transaction
      t.string :medium
      t.references :account, index: true, foreign_key: true
      t.timestamps null: false
      t.decimal :amount
      t.string :from
      t.string :where
      t.decimal :balance
      t.string :remark
    end
  
  
    create_table :accounts do |t|
      t.references :user, index: true, foreign_key: true
      t.bigint :number
      t.string :type_of_account
      t.references :branch, index: true, foreign_key: true
      t.decimal :balance
      t.timestamps null: false
    end

    create_table :atms do |t|
      t.bigint :number
      t.integer :cvv 
      t.date :expiry_date
      t.references :account, index: true, foreign_key: true
      t.timestamps null: false
    end

    create_table :loan_types do |t|
      t.string :name
      t.integer  :interest
      t.timestamps null: false
    end
    
    create_table :loans do |t|
      t.integer  :duration
      t.references :loan_type, index: true, foreign_key: true
      t.references :account, index: true, foreign_key: true
      t.bigint :amount
      t.timestamps null: false
    end
  end
end
