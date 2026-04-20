class AddContentFormatToTechInfos < ActiveRecord::Migration[8.1]
  def change
    add_column :tech_infos, :content_format, :string, default: "markdown", null: false
  end
end
