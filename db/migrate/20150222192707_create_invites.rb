class CreateInvites < ActiveRecord::Migration
  def change
    create_table :invites do |t|
      t.integer :user_id, index: true, null: false
      t.string :invitee, null: false

      t.timestamps
    end
  end
end
