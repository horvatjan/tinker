class UserStatusField < ActiveRecord::Migration
  def change
    add_column :users, :registration_status, :integer, null: false, default: 0
  end
end
