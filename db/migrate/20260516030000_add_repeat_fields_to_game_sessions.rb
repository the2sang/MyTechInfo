class AddRepeatFieldsToGameSessions < ActiveRecord::Migration[8.1]
  def change
    add_column :game_sessions, :repeat_type, :integer, default: 0, null: false
    add_column :game_sessions, :repeat_days, :string
    add_column :game_sessions, :repeat_ends_on, :date
    add_column :game_sessions, :template_id, :integer

    add_index :game_sessions, :template_id
    add_index :game_sessions, :repeat_type
  end
end
