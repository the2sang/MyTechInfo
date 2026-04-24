class CreateLifeInfos < ActiveRecord::Migration[8.1]
  def change
    create_table :life_infos do |t|
      t.string  :title,          null: false
      t.text    :content,        null: false
      t.string  :content_format, null: false, default: "html"
      t.string  :category
      t.string  :reference_url
      t.boolean :is_public,      null: false, default: false
      t.references :user,        null: false, foreign_key: true

      t.timestamps
    end
  end
end
