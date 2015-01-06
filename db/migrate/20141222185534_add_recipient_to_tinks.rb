class AddRecipientToTinks < ActiveRecord::Migration
  def change
    add_column :tinks, :recipient_id, :integer, null: false, index: true
  end
end
