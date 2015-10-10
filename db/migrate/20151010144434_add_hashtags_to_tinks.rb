class AddHashtagsToTinks < ActiveRecord::Migration
  def change
    add_column :tinks, :hashtags, :string, null: true
  end
end
