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

ActiveRecord::Schema[8.1].define(version: 2026_09_05_200500) do
  create_table "check_ins", force: :cascade do |t|
    t.date "checked_in_on", null: false
    t.datetime "created_at", null: false
    t.integer "plan_id", null: false
    t.text "reflection", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["plan_id"], name: "index_check_ins_on_plan_id"
    t.index ["user_id"], name: "index_check_ins_on_user_id"
  end

  create_table "exports", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "error_message"
    t.string "file_path"
    t.integer "plan_id", null: false
    t.string "status", default: "queued", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["plan_id"], name: "index_exports_on_plan_id"
    t.index ["user_id"], name: "index_exports_on_user_id"
  end

  create_table "goals", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.date "due_date"
    t.integer "plan_id", null: false
    t.integer "position", default: 0, null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["plan_id"], name: "index_goals_on_plan_id"
    t.index ["user_id"], name: "index_goals_on_user_id"
  end

  create_table "plans", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "end_date", null: false
    t.text "purpose"
    t.date "start_date", null: false
    t.string "status", default: "active", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_plans_on_user_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "tasks", force: :cascade do |t|
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.integer "goal_id", null: false
    t.integer "plan_id", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["goal_id"], name: "index_tasks_on_goal_id"
    t.index ["plan_id"], name: "index_tasks_on_plan_id"
    t.index ["user_id"], name: "index_tasks_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  create_table "xp_entries", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "event_id", default: "", null: false
    t.string "kind", null: false
    t.integer "plan_id", null: false
    t.integer "points", null: false
    t.string "signature", null: false
    t.integer "task_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["event_id"], name: "index_xp_entries_on_event_id", unique: true
    t.index ["plan_id"], name: "index_xp_entries_on_plan_id"
    t.index ["signature"], name: "index_xp_entries_on_signature", unique: true
    t.index ["task_id"], name: "index_xp_entries_on_task_id"
    t.index ["user_id"], name: "index_xp_entries_on_user_id"
  end

  add_foreign_key "check_ins", "plans"
  add_foreign_key "check_ins", "users"
  add_foreign_key "exports", "plans"
  add_foreign_key "exports", "users"
  add_foreign_key "goals", "plans"
  add_foreign_key "goals", "users"
  add_foreign_key "plans", "users"
  add_foreign_key "sessions", "users"
  add_foreign_key "tasks", "goals"
  add_foreign_key "tasks", "plans"
  add_foreign_key "tasks", "users"
  add_foreign_key "xp_entries", "plans"
  add_foreign_key "xp_entries", "tasks"
  add_foreign_key "xp_entries", "users"
end
