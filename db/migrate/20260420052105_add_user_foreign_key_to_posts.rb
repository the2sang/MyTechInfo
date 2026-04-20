class AddUserForeignKeyToPosts < ActiveRecord::Migration[8.1]
  def change
    # Remove existing test data that has no valid user
    execute "DELETE FROM posts WHERE user_id IS NULL OR user_id NOT IN (SELECT id FROM users)" rescue nil

    change_column_null :posts, :user_id, false
    add_foreign_key :posts, :users
    add_index :posts, :user_id
  end
end
