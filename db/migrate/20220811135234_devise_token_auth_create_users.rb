class DeviseTokenAuthCreateUsers < ActiveRecord::Migration[6.0]
  def change
    
    
      

     add_column :users, :provider, :string, :null => false, :default => "email"
     add_column :users, :uid, :string, :null => false, :default => ""
    add_column :users, :tokens, :text
    #Ex:- add_column("admin_users", "username", :string, :limit =>25, :after => "email")
     
      
  
    # add_index :users, :unlock_token,         unique: true
  end
end
