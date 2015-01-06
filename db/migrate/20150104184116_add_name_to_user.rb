class AddNameToUser < ActiveRecord::Migration
  def change
    add_column :users, :name, :string, null: true, index: true
  end
end
