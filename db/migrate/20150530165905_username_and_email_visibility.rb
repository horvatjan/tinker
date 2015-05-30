class UsernameAndEmailVisibility < ActiveRecord::Migration
  def change
    add_column :users, :username, :string, null: true
    add_column :users, :email_visibility, :integer, null: false, default: 1
  end
end
