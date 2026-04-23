class CreateTelegramPrompts < ActiveRecord::Migration[8.1]
  def change
    create_table :telegram_prompts do |t|
      t.string :chat_id, null: false
      t.integer :telegram_message_id
      t.string :command
      t.text :message_text, null: false
      t.string :status, null: false, default: "pending"
      t.text :result
      t.text :error_message
      t.datetime :processed_at

      t.timestamps
    end

    add_index :telegram_prompts, :chat_id
    add_index :telegram_prompts, :status
    add_index :telegram_prompts, [ :chat_id, :telegram_message_id ], unique: true
  end
end
