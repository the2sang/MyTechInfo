class CreateTechInfoReactions < ActiveRecord::Migration[8.1]
  def change
    create_table :tech_info_reactions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :tech_info, null: false, foreign_key: true
      t.integer :kind, null: false

      t.timestamps
    end

    add_index :tech_info_reactions, [:user_id, :tech_info_id], unique: true
  end
end
