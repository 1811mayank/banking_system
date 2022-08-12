class New < ActiveRecord::Migration[6.0]
  def change
    
add_column :users, :sign_in_count, :integer, default: 0, null: false
add_column :users, :current_sign_in_at, :datetime
add_column :users, :last_sign_in_at, :datetime
add_column :users, :current_sign_in_ip, :inlet
add_column :users, :last_sign_in_ip, :inlet
#Ex:- add_column("admin_users", "username", :string, :limit =>25, :after => "email")
#Ex:- add_column("admin_users", "username", :string, :limit =>25, :after => "email")
  end
end
