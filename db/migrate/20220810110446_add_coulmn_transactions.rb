class AddCoulmnTransactions < ActiveRecord::Migration[6.0]
  def change
    add_column :transactions, :balance, :decimal
  end
end
