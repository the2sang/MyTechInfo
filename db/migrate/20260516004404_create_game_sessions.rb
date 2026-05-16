class CreateGameSessions < ActiveRecord::Migration[8.1]
  def change
    create_table :game_sessions do |t|
      t.integer :club_id,          null: false
      t.string  :title,            null: false
      t.string  :venue_name,       null: false
      t.string  :address
      t.date    :scheduled_date,   null: false
      t.time    :start_time,       null: false
      t.time    :end_time,         null: false
      t.integer :court_count,      default: 1
      t.integer :fee,              default: 0, null: false
      t.text    :notes
      t.integer :max_participants
      t.integer :visibility,       null: false, default: 0
      t.integer :status,           null: false, default: 0
      t.timestamps
    end
    add_index :game_sessions, :club_id
    add_index :game_sessions, :scheduled_date
    add_index :game_sessions, [ :club_id, :scheduled_date ]
    add_foreign_key :game_sessions, :clubs
  end
end
