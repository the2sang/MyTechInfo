class AddContactFieldsToClubs < ActiveRecord::Migration[8.1]
  def change
    add_column :clubs, :contact_phone, :string
    add_column :clubs, :contact_email, :string
  end
end
