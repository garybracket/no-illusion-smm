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

ActiveRecord::Schema[7.2].define(version: 2025_08_21_005219) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "platform_connections", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "platform_name"
    t.text "access_token"
    t.text "refresh_token"
    t.datetime "expires_at"
    t.json "settings"
    t.boolean "is_active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_platform_connections_on_user_id"
  end

  create_table "posts", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.text "content"
    t.text "platforms"
    t.string "status"
    t.string "content_mode"
    t.boolean "ai_generated"
    t.datetime "scheduled_for"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_posts_on_user_id"
  end

  create_table "prompt_templates", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "name"
    t.text "prompt_text"
    t.string "content_mode"
    t.boolean "is_system"
    t.boolean "is_public"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_prompt_templates_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "name", null: false
    t.text "bio"
    t.text "skills", default: [], array: true
    t.text "mission_statement"
    t.integer "content_mode", default: 0
    t.boolean "ai_enabled", default: true
    t.json "ai_preferences", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "auth0_id"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.index ["auth0_id"], name: "index_users_on_auth0_id", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "platform_connections", "users"
  add_foreign_key "posts", "users"
  add_foreign_key "prompt_templates", "users"
end
