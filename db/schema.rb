# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_08_14_092134) do

  create_table "machines", force: :cascade do |t|
    t.string "ip"
    t.string "external_ip"
    t.integer "cpu"
    t.integer "ram"
    t.integer "disk"
    t.text "username"
    t.text "password"
    t.string "machine_type"
    t.integer "pool_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["pool_id"], name: "index_machines_on_pool_id"
  end

  create_table "pools", force: :cascade do |t|
    t.string "cluster"
    t.string "storage_domain"
    t.string "template"
    t.string "instance_type"
    t.integer "masters"
    t.integer "slaves"
    t.integer "post_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "pool_type"
    t.index ["post_id"], name: "index_pools_on_post_id"
  end

  create_table "posts", force: :cascade do |t|
    t.string "title"
    t.text "content"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "email"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "email", null: false
    t.string "encrypted_password", limit: 128, null: false
    t.string "confirmation_token", limit: 128
    t.string "remember_token", limit: 128, null: false
    t.index ["email"], name: "index_users_on_email"
    t.index ["remember_token"], name: "index_users_on_remember_token"
  end

  add_foreign_key "machines", "pools"
  add_foreign_key "pools", "posts"
end
