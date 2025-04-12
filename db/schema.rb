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

ActiveRecord::Schema[8.0].define(version: 2025_03_06_141403) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "chart_datas", force: :cascade do |t|
    t.bigint "worker_id", null: false
    t.datetime "label"
    t.decimal "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["worker_id"], name: "index_chart_datas_on_worker_id"
  end

  create_table "pools", force: :cascade do |t|
    t.decimal "best_difficulty"
    t.string "period", default: "1.hour", null: false
    t.integer "workers_count", default: 0, null: false
    t.string "host", default: "umbrel.local", null: false
    t.string "port", default: "2019", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.decimal "best_difficulty", default: "0.0", null: false
    t.integer "workers_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "workers", force: :cascade do |t|
    t.string "name"
    t.bigint "user_id", null: false
    t.string "session_id"
    t.decimal "best_difficulty"
    t.decimal "hash_rate"
    t.datetime "start_time"
    t.datetime "last_seen"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_workers_on_user_id"
  end

  add_foreign_key "chart_datas", "workers"
  add_foreign_key "workers", "users"
end
