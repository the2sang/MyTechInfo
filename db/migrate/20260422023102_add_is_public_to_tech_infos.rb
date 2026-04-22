class AddIsPublicToTechInfos < ActiveRecord::Migration[8.1]
  def change
    add_column :tech_infos, :is_public, :boolean, default: false, null: false
  end
end
