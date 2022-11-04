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

ActiveRecord::Schema[7.0].define(version: 2022_11_04_183204) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_trgm"
  enable_extension "plpgsql"

  create_table "links", force: :cascade do |t|
    t.string "url"
    t.string "title"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "open_graph_description", default: ""
    t.datetime "published_at", precision: nil
    t.index ["url"], name: "index_links_on_url", opclass: :gin_trgm_ops, using: :gin
  end

  create_table "shares", force: :cascade do |t|
    t.bigint "link_id", null: false
    t.string "shortened_url"
    t.string "utm_source"
    t.string "utm_medium"
    t.string "utm_campaign"
    t.string "utm_term"
    t.string "utm_content"
    t.string "utm_id"
    t.string "shared_link_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["link_id"], name: "index_shares_on_link_id"
  end

  add_foreign_key "shares", "links"
end
