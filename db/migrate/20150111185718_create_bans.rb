class CreateBans < ActiveRecord::Migration
  def change
    create_table :bans do |t|
      t.integer :user_id, index: true, null: false
      t.integer :banned_id, index: true, null: false

      t.timestamps
    end
  end
end
