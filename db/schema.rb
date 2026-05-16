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

ActiveRecord::Schema[8.1].define(version: 2026_05_16_113237) do
  create_table "club_memberships", force: :cascade do |t|
    t.integer "club_id", null: false
    t.datetime "created_at", null: false
    t.integer "role", default: 0, null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["club_id", "user_id"], name: "index_club_memberships_on_club_id_and_user_id", unique: true
    t.index ["club_id"], name: "index_club_memberships_on_club_id"
    t.index ["user_id"], name: "index_club_memberships_on_user_id"
  end

  create_table "clubs", force: :cascade do |t|
    t.string "contact_email"
    t.string "contact_phone"
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name", null: false
    t.integer "owner_id", null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_clubs_on_name", unique: true
    t.index ["owner_id"], name: "index_clubs_on_owner_id"
    t.index ["status"], name: "index_clubs_on_status"
  end

  create_table "comments", force: :cascade do |t|
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.integer "tech_info_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["tech_info_id"], name: "index_comments_on_tech_info_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "game_sessions", force: :cascade do |t|
    t.string "address"
    t.integer "club_id", null: false
    t.integer "court_count", default: 1
    t.datetime "created_at", null: false
    t.time "end_time", null: false
    t.integer "fee", default: 0, null: false
    t.integer "max_participants"
    t.text "notes"
    t.string "repeat_days"
    t.date "repeat_ends_on"
    t.integer "repeat_type", default: 0, null: false
    t.date "scheduled_date", null: false
    t.time "start_time", null: false
    t.integer "status", default: 0, null: false
    t.integer "template_id"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.string "venue_name", null: false
    t.integer "visibility", default: 0, null: false
    t.index ["club_id", "scheduled_date"], name: "index_game_sessions_on_club_id_and_scheduled_date"
    t.index ["club_id"], name: "index_game_sessions_on_club_id"
    t.index ["repeat_type"], name: "index_game_sessions_on_repeat_type"
    t.index ["scheduled_date"], name: "index_game_sessions_on_scheduled_date"
    t.index ["template_id"], name: "index_game_sessions_on_template_id"
  end

  create_table "group_memberships", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "group_id", null: false
    t.integer "role", default: 0, null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["group_id", "user_id"], name: "index_group_memberships_on_group_id_and_user_id", unique: true
    t.index ["group_id"], name: "index_group_memberships_on_group_id"
    t.index ["user_id"], name: "index_group_memberships_on_user_id"
  end

  create_table "groups", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.integer "owner_id", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_groups_on_name"
    t.index ["owner_id"], name: "index_groups_on_owner_id"
  end

  create_table "guest_applications", force: :cascade do |t|
    t.integer "club_id", null: false
    t.datetime "created_at", null: false
    t.string "email"
    t.text "message"
    t.string "name", null: false
    t.string "phone", null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["club_id", "status"], name: "index_guest_applications_on_club_id_and_status"
    t.index ["club_id"], name: "index_guest_applications_on_club_id"
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

  create_table "manpower_records", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description", null: false
    t.date "end_date", null: false
    t.date "request_date", null: false
    t.date "start_date", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.integer "work_minutes", null: false
    t.index ["user_id", "request_date"], name: "index_manpower_records_on_user_id_and_request_date"
    t.index ["user_id"], name: "index_manpower_records_on_user_id"
  end

  create_table "memos", force: :cascade do |t|
    t.text "content"
    t.datetime "created_at", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_memos_on_user_id"
  end

  create_table "participations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "game_session_id", null: false
    t.integer "participation_type", default: 0, null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["game_session_id", "user_id"], name: "index_participations_on_session_and_member", unique: true, where: "user_id IS NOT NULL"
    t.index ["game_session_id"], name: "index_participations_on_game_session_id"
    t.index ["user_id"], name: "index_participations_on_user_id"
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
    t.integer "age_group", default: 0, null: false
    t.datetime "created_at", null: false
    t.string "display_name"
    t.string "dupr_id"
    t.datetime "dupr_last_synced_at"
    t.decimal "dupr_rating", precision: 4, scale: 2
    t.string "email_address", null: false
    t.integer "gender", default: 0, null: false
    t.string "nickname", null: false
    t.string "password_digest"
    t.datetime "profile_completed_at"
    t.string "region"
    t.integer "role", default: 0, null: false
    t.integer "sport_level", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["dupr_id"], name: "index_users_on_dupr_id"
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
    t.index ["nickname"], name: "index_users_on_nickname", unique: true
    t.index ["role"], name: "index_users_on_role"
  end

  create_table "work_journals", force: :cascade do |t|
    t.integer "category", default: 0, null: false
    t.text "content", default: ""
    t.string "content_format", default: "markdown", null: false
    t.datetime "created_at", null: false
    t.integer "entry_type", default: 0, null: false
    t.boolean "is_draft", default: false, null: false
    t.integer "progress", default: 0, null: false
    t.integer "sequence_number", default: 1, null: false
    t.integer "status", default: 0, null: false
    t.string "title", limit: 200, null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.date "work_date", null: false
    t.index ["user_id", "category"], name: "index_work_journals_on_user_id_and_category"
    t.index ["user_id", "is_draft"], name: "index_work_journals_on_user_id_and_is_draft"
    t.index ["user_id", "status"], name: "index_work_journals_on_user_id_and_status"
    t.index ["user_id", "work_date", "entry_type"], name: "index_work_journals_on_user_date_type"
    t.index ["user_id", "work_date"], name: "index_work_journals_on_user_id_and_work_date"
    t.index ["user_id"], name: "index_work_journals_on_user_id"
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

  add_foreign_key "club_memberships", "clubs"
  add_foreign_key "club_memberships", "users"
  add_foreign_key "clubs", "users", column: "owner_id"
  add_foreign_key "comments", "tech_infos"
  add_foreign_key "comments", "users"
  add_foreign_key "game_sessions", "clubs"
  add_foreign_key "group_memberships", "groups"
  add_foreign_key "group_memberships", "users"
  add_foreign_key "groups", "users", column: "owner_id"
  add_foreign_key "guest_applications", "clubs"
  add_foreign_key "identities", "users"
  add_foreign_key "life_infos", "users"
  add_foreign_key "manpower_records", "users"
  add_foreign_key "memos", "users"
  add_foreign_key "participations", "game_sessions"
  add_foreign_key "participations", "users"
  add_foreign_key "pomodoro_settings", "users"
  add_foreign_key "posts", "users"
  add_foreign_key "sessions", "users"
  add_foreign_key "stock_infos", "users"
  add_foreign_key "tech_info_reactions", "tech_infos"
  add_foreign_key "tech_info_reactions", "users"
  add_foreign_key "tech_infos", "users"
  add_foreign_key "work_journals", "users"
  add_foreign_key "work_plans", "users"
end
