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

ActiveRecord::Schema.define(version: 20130514030245) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "connections", force: :cascade do |t|
    t.integer  "capacity",   default: 10
    t.integer  "source_id",               null: false
    t.integer  "target_id",               null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "cost",       default: 10, null: false
  end

  add_index "connections", ["source_id", "target_id"], name: "index_connections_on_source_id_and_target_id", unique: true, using: :btree
  add_index "connections", ["target_id"], name: "index_connections_on_target_id", using: :btree

  create_table "nodes", force: :cascade do |t|
    t.integer  "project_id",             null: false
    t.string   "name"
    t.integer  "left",       default: 0
    t.integer  "top",        default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "nodes", ["project_id"], name: "index_nodes_on_project_id", using: :btree

  create_table "projects", force: :cascade do |t|
    t.integer  "user_id",    null: false
    t.string   "name",       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "projects", ["name"], name: "index_projects_on_name", unique: true, using: :btree
  add_index "projects", ["user_id"], name: "index_projects_on_user_id", using: :btree

  create_table "requests", force: :cascade do |t|
    t.integer  "size",       default: 10, null: false
    t.integer  "source_id",               null: false
    t.integer  "target_id",               null: false
    t.integer  "lifetime",   default: 10, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "project_id",              null: false
    t.integer  "start_time", default: 0,  null: false
    t.boolean  "success"
    t.text     "path"
  end

  add_index "requests", ["lifetime"], name: "index_requests_on_lifetime", using: :btree
  add_index "requests", ["project_id"], name: "index_requests_on_project_id", using: :btree
  add_index "requests", ["source_id", "target_id"], name: "index_requests_on_source_id_and_target_id", using: :btree
  add_index "requests", ["start_time"], name: "index_requests_on_start_time", using: :btree
  add_index "requests", ["target_id"], name: "index_requests_on_target_id", using: :btree

  create_table "timers", force: :cascade do |t|
    t.integer  "project_id",             null: false
    t.integer  "time",                   null: false
    t.text     "capacities_matrix_text", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "timers", ["project_id"], name: "index_timers_on_project_id", using: :btree
  add_index "timers", ["time"], name: "index_timers_on_time", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
