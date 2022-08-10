class CreateLoan < ActiveRecord::Migration[6.0]
  def change
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
