class CreateGroupMemberships < ActiveRecord::Migration[8.1]
  def change
    create_table :group_memberships do |t|
      t.references :group, null: false, foreign_key: true
      t.references :user,  null: false, foreign_key: true
      t.integer    :role,  null: false, default: 0
      t.timestamps
    end

    add_index :group_memberships, %i[group_id user_id], unique: true
  end
end
