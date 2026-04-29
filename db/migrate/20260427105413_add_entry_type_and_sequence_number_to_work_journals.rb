class AddEntryTypeAndSequenceNumberToWorkJournals < ActiveRecord::Migration[8.1]
  def change
    add_column :work_journals, :entry_type, :integer, null: false, default: 0
    add_column :work_journals, :sequence_number, :integer, null: false, default: 1
    add_index :work_journals, %i[user_id work_date entry_type], name: "index_work_journals_on_user_date_type"
  end
end
