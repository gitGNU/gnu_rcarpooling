# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100316131951) do

  create_table "black_list_drivers_entries", :force => true do |t|
    t.integer  "user_id"
    t.integer  "driver_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "black_list_passengers_entries", :force => true do |t|
    t.integer  "user_id"
    t.integer  "passenger_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "demands", :force => true do |t|
    t.integer  "suitor_id"
    t.datetime "earliest_departure_time"
    t.datetime "latest_arrival_time"
    t.datetime "expiry_time"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "departure_place_id"
    t.integer  "arrival_place_id"
    t.integer  "default_reply_job_number"
  end

  create_table "edges", :force => true do |t|
    t.string   "type"
    t.integer  "departure_place_id"
    t.integer  "arrival_place_id"
    t.integer  "length"
    t.integer  "travel_duration"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "fulfilled_demands", :force => true do |t|
    t.integer  "demand_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "languages", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "offerings", :force => true do |t|
    t.integer  "departure_place_id"
    t.integer  "arrival_place_id"
    t.datetime "departure_time"
    t.datetime "expiry_time"
    t.integer  "length"
    t.integer  "offerer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "seating_capacity"
    t.datetime "arrival_time"
    t.integer  "passengers_list_job_number"
  end

  create_table "places", :force => true do |t|
    t.string   "name"
    t.string   "city"
    t.string   "street"
    t.string   "civic_number"
    t.float    "latitude"
    t.float    "longitude"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "segments", :force => true do |t|
    t.string   "type"
    t.integer  "order_number"
    t.integer  "departure_place_id"
    t.integer  "arrival_place_id"
    t.datetime "departure_time"
    t.integer  "length"
    t.integer  "travel_duration"
    t.integer  "vehicle_offering_id"
    t.integer  "fulfilled_demand_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "used_offerings", :force => true do |t|
    t.integer  "offering_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "seating_capacity"
  end

  create_table "users", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "nick_name"
    t.string   "email"
    t.string   "password"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "score",           :default => 0
    t.integer  "language_id"
    t.string   "sex"
    t.integer  "max_foot_length", :default => 3000
  end

end
