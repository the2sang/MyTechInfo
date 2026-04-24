class CreateStockInfos < ActiveRecord::Migration[8.1]
  def change
    create_table :stock_infos do |t|
      t.string   :query,      null: false
      t.text     :content,    null: false
      t.datetime :queried_at, null: false
      t.references :user, null: true, foreign_key: true

      t.timestamps
    end
  end
end
