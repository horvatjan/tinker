class TinkText < ActiveRecord::Migration
  def change
    add_column :tinks, :text, :string, null: true
  end
end
