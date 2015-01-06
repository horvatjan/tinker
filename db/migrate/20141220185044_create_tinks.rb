class CreateTinks < ActiveRecord::Migration
  def change
    create_table :tinks do |t|
      t.integer :user_id, index: true, null: false
      t.integer :read, null: false

      t.timestamps
    end
  end
end
