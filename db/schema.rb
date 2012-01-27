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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120126202650) do

  create_table "achievements", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.string   "criteria"
    t.integer  "points"
    t.integer  "path_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "owner_id"
  end

  create_table "companies", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "enable_company_store", :default => true
    t.integer  "owner_id"
  end

  create_table "company_users", :force => true do |t|
    t.string   "email"
    t.integer  "user_id"
    t.integer  "company_id"
    t.string   "token1"
    t.string   "token2"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_admin"
    t.integer  "owner_id"
  end

  create_table "completed_tasks", :force => true do |t|
    t.integer  "user_id"
    t.integer  "task_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "status_id",    :default => 0
    t.datetime "quiz_session"
    t.integer  "owner_id"
  end

  create_table "enrollments", :force => true do |t|
    t.integer  "user_id"
    t.integer  "path_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "total_points", :default => 0
    t.integer  "owner_id"
  end

  add_index "enrollments", ["path_id"], :name => "index_enrollments_on_path_id"
  add_index "enrollments", ["user_id", "path_id"], :name => "index_enrollments_on_user_id_and_path_id"
  add_index "enrollments", ["user_id"], :name => "index_enrollments_on_user_id"

  create_table "info_resources", :force => true do |t|
    t.string   "description"
    t.string   "link"
    t.integer  "path_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "owner_id"
  end

  add_index "info_resources", ["path_id"], :name => "index_info_resources_on_path_id"

  create_table "paths", :force => true do |t|
    t.string   "name"
    t.text     "description",       :limit => 255
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "company_id"
    t.string   "image_url"
    t.boolean  "is_public",                        :default => false
    t.integer  "purchased_path_id"
    t.boolean  "is_published",                     :default => false
    t.boolean  "is_purchaseable",                  :default => false
    t.integer  "owner_id"
  end

  add_index "paths", ["user_id"], :name => "index_modules_on_user_id"

  create_table "rewards", :force => true do |t|
    t.integer  "company_id"
    t.string   "name"
    t.string   "description"
    t.integer  "points"
    t.string   "image_url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "owner_id"
  end

  create_table "sections", :force => true do |t|
    t.integer  "path_id"
    t.string   "name"
    t.text     "instructions", :limit => 255
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "owner_id"
  end

  create_table "tasks", :force => true do |t|
    t.string   "question"
    t.string   "answer1"
    t.string   "resource"
    t.integer  "points"
    t.integer  "section_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "answer2"
    t.string   "answer3"
    t.string   "answer4"
    t.integer  "correct_answer", :default => 1
    t.integer  "owner_id"
  end

  add_index "tasks", ["section_id"], :name => "index_tasks_on_path_id"

  create_table "user_achievements", :force => true do |t|
    t.integer  "achievement_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "owner_id"
  end

  create_table "user_transactions", :force => true do |t|
    t.integer  "user_id"
    t.integer  "reward_id"
    t.integer  "task_id"
    t.float    "amount"
    t.integer  "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "path_id"
    t.integer  "owner_id"
  end

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "encrypted_password"
    t.string   "salt"
    t.boolean  "admin",              :default => false
    t.integer  "earned_points",      :default => 0
    t.integer  "spent_points",       :default => 0
    t.string   "image_url"
    t.integer  "owner_id"
    t.string   "signup_token"
    t.integer  "company_id"
    t.boolean  "company_admin",      :default => false
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true

end
