class CreateParticipations < ActiveRecord::Migration[8.1]
  def change
    create_table :participations do |t|
      t.integer :game_session_id, null: false
      t.integer :user_id
      t.string  :guest_name
      t.integer :guest_sport_level, default: 0
      t.string  :guest_region
      t.integer :status,            null: false, default: 0
      t.timestamps
    end
    add_index :participations, :game_session_id
    add_index :participations, :user_id
    add_index :participations, [ :game_session_id, :user_id ],
              unique: true, where: "user_id IS NOT NULL",
              name: "index_participations_on_session_and_member"
    add_foreign_key :participations, :game_sessions
    add_foreign_key :participations, :users
  end
end
