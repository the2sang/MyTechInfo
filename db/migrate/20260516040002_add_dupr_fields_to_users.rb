class AddDuprFieldsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :dupr_id, :string
    add_column :users, :dupr_rating, :decimal, precision: 4, scale: 2
    add_column :users, :dupr_last_synced_at, :datetime
    add_index :users, :dupr_id
  end
end
