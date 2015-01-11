class CreateApnsTokens < ActiveRecord::Migration
  def change
    create_table :apns_tokens do |t|
      t.references :user, index: true, null: false
      t.string :token, null: false

      t.timestamps
    end
  end
end
