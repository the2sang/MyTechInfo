class MakeWorkJournalContentOptional < ActiveRecord::Migration[8.1]
  def change
    change_column_default :work_journals, :content, from: nil, to: ""
    change_column_null :work_journals, :content, true, ""
  end
end
