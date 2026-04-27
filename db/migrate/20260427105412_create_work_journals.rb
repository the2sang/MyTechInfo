class CreateWorkJournals < ActiveRecord::Migration[8.1]
  def change
    create_table :work_journals do |t|
      t.references :user,           null: false, foreign_key: true
      t.string  :title,             null: false, limit: 200
      t.text    :content,           null: false
      t.string  :content_format,    null: false, default: "markdown"
      t.integer :category,          null: false, default: 0
      t.integer :status,            null: false, default: 0
      t.integer :progress,          null: false, default: 0
      t.date    :work_date,         null: false
      t.boolean :is_draft,          null: false, default: false
      t.timestamps
    end

    add_index :work_journals, [ :user_id, :work_date ]
    add_index :work_journals, [ :user_id, :status ]
    add_index :work_journals, [ :user_id, :category ]
    add_index :work_journals, [ :user_id, :is_draft ]
  end
end
