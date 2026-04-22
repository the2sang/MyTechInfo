class AddNicknameToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :nickname, :string

    User.reset_column_information
    User.find_each do |user|
      default_nick = user.email_address.split("@").first
      user.update_columns(nickname: default_nick)
    end

    change_column_null :users, :nickname, false
    add_index :users, :nickname, unique: true
  end
end
