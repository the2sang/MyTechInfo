class CreateManpowerRecords < ActiveRecord::Migration[8.1]
  def change
    create_table :manpower_records do |t|
      t.references :user, null: false, foreign_key: true
      t.date :request_date, null: false
      t.date :start_date, null: false
      t.date :end_date, null: false
      t.integer :work_minutes, null: false
      t.text :description, null: false

      t.timestamps
    end

    add_index :manpower_records, [ :user_id, :request_date ]
  end
end
