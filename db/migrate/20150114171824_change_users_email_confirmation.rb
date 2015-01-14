class ChangeUsersEmailConfirmation < ActiveRecord::Migration
  def change
    add_column :users, :active, :integer, default: 0
    add_column :users, :email_confirmation_code, :string, null: true
    remove_column :users, :reset_password_token
    remove_column :users, :reset_password_sent_at
    remove_column :users, :remember_created_at
  end
end
