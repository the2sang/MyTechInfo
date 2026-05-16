class AddParticipationTypeToParticipations < ActiveRecord::Migration[8.1]
  def change
    add_column :participations, :participation_type, :integer, default: 0, null: false
    # Backfill: existing records with user_id are member-type
    up_only { execute "UPDATE participations SET participation_type = 0" }
    change_column_null :participations, :user_id, false
    remove_column :participations, :guest_name,        :string
    remove_column :participations, :guest_sport_level, :integer
    remove_column :participations, :guest_region,      :string
  end
end
