class CreateTechInfos < ActiveRecord::Migration[8.1]
  def change
    create_table :tech_infos do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.string :reference_url
      t.string :related_tech
      t.text :content, null: false
      t.text :extra_info
      t.integer :usefulness, null: false

      t.timestamps
    end
  end
end
