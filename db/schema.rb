# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150118173433) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "apns_tokens", force: true do |t|
    t.integer  "user_id"
    t.string   "token",      null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "apns_tokens", ["user_id"], name: "index_apns_tokens_on_user_id", using: :btree

  create_table "bans", force: true do |t|
    t.integer  "user_id",    null: false
    t.integer  "banned_id",  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "friends", force: true do |t|
    t.integer  "user_id",    null: false
    t.integer  "friend_id",  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tinks", force: true do |t|
    t.integer  "user_id",      null: false
    t.integer  "read",         null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "recipient_id", null: false
  end

  create_table "users", force: true do |t|
    t.string   "email",                   default: "", null: false
    t.string   "encrypted_password",      default: "", null: false
    t.integer  "sign_in_count",           default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "authentication_token"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "token_expiration"
    t.string   "name"
    t.integer  "active",                  default: 0
    t.string   "email_confirmation_code"
    t.string   "uid"
    t.string   "provider"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree

end
