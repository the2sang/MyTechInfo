class CreatePomodoroSettings < ActiveRecord::Migration[8.1]
  def change
    create_table :pomodoro_settings do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.integer :focus_minutes, null: false, default: 25
      t.integer :break_minutes, null: false, default: 5

      t.timestamps
    end
  end
end
