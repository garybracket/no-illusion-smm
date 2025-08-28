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

ActiveRecord::Schema[7.2].define(version: 2025_08_28_030208) do
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
    t.string "platform_user_id"
    t.index ["user_id"], name: "index_platform_connections_on_user_id"
  end

  create_table "post_variants", force: :cascade do |t|
    t.bigint "post_id", null: false
    t.string "platform_key"
    t.string "content_hash"
    t.integer "content_length"
    t.integer "ai_tokens_used"
    t.datetime "generated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["post_id"], name: "index_post_variants_on_post_id"
  end

  create_table "posts", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.text "platforms"
    t.integer "status", default: 0, null: false
    t.integer "content_mode", default: 0, null: false
    t.boolean "ai_generated"
    t.datetime "scheduled_for"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "content_length"
    t.string "content_hash"
    t.json "platform_post_ids", default: {}
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
    t.boolean "is_active", default: false
    t.index ["user_id", "content_mode", "is_active"], name: "idx_on_user_id_content_mode_is_active_085dae4055"
    t.index ["user_id"], name: "index_prompt_templates_on_user_id"
  end

  create_table "subscription_tiers", force: :cascade do |t|
    t.string "name"
    t.string "slug"
    t.integer "price_cents"
    t.string "billing_interval"
    t.json "features"
    t.json "limits"
    t.boolean "is_active"
    t.integer "sort_order"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.text "professional_summary"
    t.json "work_experience", default: []
    t.json "education", default: []
    t.json "certifications", default: []
    t.string "phone"
    t.string "linkedin_url"
    t.string "github_url"
    t.string "portfolio_url"
    t.string "location"
    t.string "resume_template", default: "modern"
    t.string "resume_color_scheme", default: "professional"
    t.datetime "last_resume_generated_at"
    t.integer "resume_version", default: 1
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "subscription_tier", default: "free"
    t.index ["auth0_id"], name: "index_users_on_auth0_id", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["subscription_tier"], name: "index_users_on_subscription_tier"
  end

  add_foreign_key "platform_connections", "users"
  add_foreign_key "post_variants", "posts"
  add_foreign_key "posts", "users"
  add_foreign_key "prompt_templates", "users"
end
