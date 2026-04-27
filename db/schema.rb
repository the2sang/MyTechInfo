# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_04_27_105411) do
  create_table "comments", force: :cascade do |t|
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.integer "tech_info_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["tech_info_id"], name: "index_comments_on_tech_info_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "identities", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "provider", null: false
    t.string "uid", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["provider", "uid"], name: "index_identities_on_provider_and_uid", unique: true
    t.index ["user_id"], name: "index_identities_on_user_id"
  end

  create_table "life_infos", force: :cascade do |t|
    t.string "category"
    t.text "content", null: false
    t.string "content_format", default: "html", null: false
    t.datetime "created_at", null: false
    t.boolean "is_public", default: false, null: false
    t.string "reference_url"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_life_infos_on_user_id"
  end

  create_table "memos", force: :cascade do |t|
    t.text "content"
    t.datetime "created_at", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_memos_on_user_id"
  end

  create_table "pomodoro_settings", force: :cascade do |t|
    t.boolean "auto_start", default: false, null: false
    t.integer "break_minutes", default: 5, null: false
    t.datetime "created_at", null: false
    t.integer "focus_minutes", default: 25, null: false
    t.integer "long_break_minutes", default: 20, null: false
    t.integer "rounds", default: 4, null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_pomodoro_settings_on_user_id", unique: true
  end

  create_table "posts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "title"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_posts_on_user_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "stock_infos", force: :cascade do |t|
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.datetime "queried_at", null: false
    t.string "query", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.index ["user_id"], name: "index_stock_infos_on_user_id"
  end

  create_table "tech_info_reactions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "kind", null: false
    t.integer "tech_info_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["tech_info_id"], name: "index_tech_info_reactions_on_tech_info_id"
    t.index ["user_id", "tech_info_id"], name: "index_tech_info_reactions_on_user_id_and_tech_info_id", unique: true
    t.index ["user_id"], name: "index_tech_info_reactions_on_user_id"
  end

  create_table "tech_infos", force: :cascade do |t|
    t.text "content", null: false
    t.string "content_format", default: "markdown", null: false
    t.datetime "created_at", null: false
    t.text "extra_info"
    t.boolean "is_public", default: false, null: false
    t.string "reference_url"
    t.string "related_tech"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.integer "usefulness", null: false
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_tech_infos_on_user_id"
  end

  create_table "telegram_prompts", force: :cascade do |t|
    t.string "chat_id", null: false
    t.string "command"
    t.datetime "created_at", null: false
    t.text "error_message"
    t.text "message_text", null: false
    t.datetime "processed_at"
    t.text "result"
    t.string "status", default: "pending", null: false
    t.integer "telegram_message_id"
    t.datetime "updated_at", null: false
    t.index ["chat_id", "telegram_message_id"], name: "index_telegram_prompts_on_chat_id_and_telegram_message_id", unique: true
    t.index ["chat_id"], name: "index_telegram_prompts_on_chat_id"
    t.index ["status"], name: "index_telegram_prompts_on_status"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "nickname", null: false
    t.string "password_digest"
    t.integer "role", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
    t.index ["nickname"], name: "index_users_on_nickname", unique: true
    t.index ["role"], name: "index_users_on_role"
  end

  create_table "work_plans", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "department_name", null: false
    t.date "doc_date", null: false
    t.text "extra_info"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.datetime "work_at", null: false
    t.text "work_content"
    t.datetime "work_end_at"
    t.string "work_name", null: false
    t.index ["user_id", "work_at"], name: "index_work_plans_on_user_id_and_work_at"
    t.index ["user_id"], name: "index_work_plans_on_user_id"
  end

  add_foreign_key "comments", "tech_infos"
  add_foreign_key "comments", "users"
  add_foreign_key "identities", "users"
  add_foreign_key "life_infos", "users"
  add_foreign_key "memos", "users"
  add_foreign_key "pomodoro_settings", "users"
  add_foreign_key "posts", "users"
  add_foreign_key "sessions", "users"
  add_foreign_key "stock_infos", "users"
  add_foreign_key "tech_info_reactions", "tech_infos"
  add_foreign_key "tech_info_reactions", "users"
  add_foreign_key "tech_infos", "users"
  add_foreign_key "work_plans", "users"
end
