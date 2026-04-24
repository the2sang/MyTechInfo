class CreateWorkPlans < ActiveRecord::Migration[8.1]
  def change
    create_table :work_plans do |t|
      t.references :user, null: false, foreign_key: true
      t.string :department_name, null: false
      t.string :work_name,       null: false
      t.datetime :work_at,       null: false
      t.text :work_content
      t.text :extra_info

      t.timestamps
    end

    add_index :work_plans, [ :user_id, :work_at ]
  end
end
