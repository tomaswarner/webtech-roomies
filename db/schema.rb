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

ActiveRecord::Schema[8.0].define(version: 2026_10_01_120012) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "amenities", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_amenities_on_name", unique: true
  end

  create_table "applications", force: :cascade do |t|
    t.bigint "listing_id", null: false
    t.bigint "seeker_id", null: false
    t.text "message", null: false
    t.date "move_in_date", null: false
    t.integer "stay_duration_months", null: false
    t.string "status", default: "pending", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["listing_id", "seeker_id"], name: "index_applications_on_listing_id_and_seeker_id", unique: true
    t.index ["listing_id"], name: "index_applications_on_listing_id"
    t.index ["listing_id"], name: "index_applications_on_listing_id_one_accepted", unique: true, where: "((status)::text = 'accepted'::text)"
    t.index ["seeker_id"], name: "index_applications_on_seeker_id"
    t.index ["status"], name: "index_applications_on_status"
  end

  create_table "listing_photos", force: :cascade do |t|
    t.bigint "listing_id", null: false
    t.string "image_url", null: false
    t.string "caption"
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["listing_id", "position"], name: "index_listing_photos_on_listing_id_and_position"
    t.index ["listing_id"], name: "index_listing_photos_on_listing_id"
  end

  create_table "listings", force: :cascade do |t|
    t.bigint "property_id", null: false
    t.string "title", null: false
    t.string "status", default: "draft", null: false
    t.decimal "monthly_rent", precision: 10, scale: 2, null: false
    t.decimal "deposit", precision: 10, scale: 2, default: "0.0", null: false
    t.date "available_on", null: false
    t.integer "minimum_stay_months", default: 1, null: false
    t.boolean "furnished", default: false, null: false
    t.boolean "private_bathroom", default: false, null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["available_on"], name: "index_listings_on_available_on"
    t.index ["property_id"], name: "index_listings_on_property_id"
    t.index ["status"], name: "index_listings_on_status"
  end

  create_table "neighborhoods", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_neighborhoods_on_name", unique: true
  end

  create_table "properties", force: :cascade do |t|
    t.bigint "host_id", null: false
    t.bigint "neighborhood_id", null: false
    t.string "address", null: false
    t.string "property_type", null: false
    t.integer "bedrooms_count", null: false
    t.integer "bathrooms_count", null: false
    t.text "shared_spaces_description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["host_id"], name: "index_properties_on_host_id"
    t.index ["neighborhood_id"], name: "index_properties_on_neighborhood_id"
  end

  create_table "property_amenities", force: :cascade do |t|
    t.bigint "property_id", null: false
    t.bigint "amenity_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["amenity_id"], name: "index_property_amenities_on_amenity_id"
    t.index ["property_id", "amenity_id"], name: "index_property_amenities_on_property_id_and_amenity_id", unique: true
    t.index ["property_id"], name: "index_property_amenities_on_property_id"
  end

  create_table "reports", force: :cascade do |t|
    t.bigint "listing_id", null: false
    t.bigint "reporter_id", null: false
    t.bigint "resolved_by_id"
    t.string "reason", null: false
    t.text "details"
    t.string "status", default: "pending", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["listing_id"], name: "index_reports_on_listing_id"
    t.index ["reporter_id"], name: "index_reports_on_reporter_id"
    t.index ["resolved_by_id"], name: "index_reports_on_resolved_by_id"
    t.index ["status"], name: "index_reports_on_status"
  end

  create_table "reviews", force: :cascade do |t|
    t.bigint "property_id", null: false
    t.bigint "visit_id", null: false
    t.bigint "seeker_id", null: false
    t.integer "rating", null: false
    t.text "comment", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["property_id"], name: "index_reviews_on_property_id"
    t.index ["seeker_id"], name: "index_reviews_on_seeker_id"
    t.index ["visit_id"], name: "index_reviews_on_visit_id", unique: true
    t.check_constraint "rating >= 1 AND rating <= 5", name: "reviews_rating_between_1_and_5"
  end

  create_table "saved_listings", force: :cascade do |t|
    t.bigint "seeker_id", null: false
    t.bigint "listing_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["listing_id"], name: "index_saved_listings_on_listing_id"
    t.index ["seeker_id", "listing_id"], name: "index_saved_listings_on_seeker_id_and_listing_id", unique: true
    t.index ["seeker_id"], name: "index_saved_listings_on_seeker_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "phone"
    t.string "role", default: "member", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  create_table "visits", force: :cascade do |t|
    t.bigint "application_id", null: false
    t.datetime "scheduled_at", null: false
    t.string "status", default: "proposed", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["application_id"], name: "index_visits_on_application_id"
    t.index ["status"], name: "index_visits_on_status"
  end

  add_foreign_key "applications", "listings"
  add_foreign_key "applications", "users", column: "seeker_id"
  add_foreign_key "listing_photos", "listings"
  add_foreign_key "listings", "properties"
  add_foreign_key "properties", "neighborhoods"
  add_foreign_key "properties", "users", column: "host_id"
  add_foreign_key "property_amenities", "amenities"
  add_foreign_key "property_amenities", "properties"
  add_foreign_key "reports", "listings"
  add_foreign_key "reports", "users", column: "reporter_id"
  add_foreign_key "reports", "users", column: "resolved_by_id"
  add_foreign_key "reviews", "properties"
  add_foreign_key "reviews", "users", column: "seeker_id"
  add_foreign_key "reviews", "visits"
  add_foreign_key "saved_listings", "listings"
  add_foreign_key "saved_listings", "users", column: "seeker_id"
  add_foreign_key "visits", "applications"
end
