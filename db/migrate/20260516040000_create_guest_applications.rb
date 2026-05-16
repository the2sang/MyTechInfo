class CreateGuestApplications < ActiveRecord::Migration[8.1]
  def change
    create_table :guest_applications do |t|
      t.references :club, null: false, foreign_key: true
      t.string :name,    null: false
      t.string :phone,   null: false
      t.string :email
      t.text   :message
      t.integer :status, default: 0, null: false

      t.timestamps
    end

    add_index :guest_applications, [ :club_id, :status ]
  end
end
