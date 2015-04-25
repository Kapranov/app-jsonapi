ActiveRecord::Schema.define(version: 20140603212327) do

  create_table "contacts", force: :cascade do |t|
    t.string   "name_first"
    t.string   "name_last"
    t.string   "email"
    t.string   "twitter"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "phone_numbers", force: :cascade do |t|
    t.integer  "contact_id"
    t.string   "name"
    t.string   "phone_number"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
