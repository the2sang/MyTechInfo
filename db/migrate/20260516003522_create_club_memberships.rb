class CreateClubMemberships < ActiveRecord::Migration[8.1]
  def change
    create_table :club_memberships do |t|
      t.integer :club_id, null: false
      t.integer :user_id, null: false
      t.integer :role,    null: false, default: 0
      t.integer :status,  null: false, default: 0
      t.timestamps
    end
    add_index :club_memberships, [:club_id, :user_id], unique: true
    add_index :club_memberships, :club_id
    add_index :club_memberships, :user_id
    add_foreign_key :club_memberships, :clubs
    add_foreign_key :club_memberships, :users
  end
end
