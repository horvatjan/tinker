class UpdateUserFbid < ActiveRecord::Migration
  def change
    remove_column :users, :uid
    remove_column :users, :provider
    add_column :users, :fbid, :string, null: true
  end
end
