class AddFieldsToPomodoroSettings < ActiveRecord::Migration[8.1]
  def change
    add_column :pomodoro_settings, :long_break_minutes, :integer, null: false, default: 20
    add_column :pomodoro_settings, :rounds,             :integer, null: false, default: 4
    add_column :pomodoro_settings, :auto_start,         :boolean, null: false, default: false
  end
end
