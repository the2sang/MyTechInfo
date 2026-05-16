class AddPbFieldsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :display_name, :string
    add_column :users, :sport_level, :integer, default: 0, null: false
    add_column :users, :age_group,   :integer, default: 0, null: false
    add_column :users, :gender,      :integer, default: 0, null: false
    add_column :users, :region, :string
  end
end
