class AddColorToTink < ActiveRecord::Migration
  def change
    add_column :tinks, :color, :integer, null: false, default: 1
  end
end
