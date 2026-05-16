class CreateClubs < ActiveRecord::Migration[8.1]
  def change
    create_table :clubs do |t|
      t.string  :name,        null: false
      t.text    :description
      t.integer :owner_id,    null: false
      t.integer :status,      null: false, default: 0
      t.timestamps
    end
    add_index :clubs, :name, unique: true
    add_index :clubs, :owner_id
    add_index :clubs, :status
    add_foreign_key :clubs, :users, column: :owner_id
  end
end
