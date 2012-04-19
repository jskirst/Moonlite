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

ActiveRecord::Schema.define(:version => 20120419190502) do

  create_table "achievements", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.string   "criteria"
    t.integer  "points"
    t.integer  "path_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "owner_id"
    t.string   "image_url"
  end

  create_table "categories", :force => true do |t|
    t.integer  "company_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "category_pic_file_name"
    t.string   "category_pic_content_type"
    t.integer  "category_pic_file_size"
    t.datetime "category_pic_updated_at"
  end

  create_table "comments", :force => true do |t|
    t.integer  "user_id"
    t.integer  "task_id"
    t.string   "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "companies", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "enable_company_store",    :default => true
    t.integer  "owner_id"
    t.boolean  "enable_leaderboard",      :default => true
    t.boolean  "enable_dashboard",        :default => true
    t.boolean  "enable_tour",             :default => true
    t.boolean  "enable_comments",         :default => true
    t.boolean  "enable_feedback",         :default => true
    t.boolean  "enable_news",             :default => true
    t.boolean  "enable_achievements",     :default => true
    t.boolean  "enable_recommendations",  :default => true
    t.boolean  "enable_printer_friendly", :default => true
    t.boolean  "enable_browsing",         :default => true
    t.boolean  "enable_user_creation",    :default => true
    t.boolean  "enable_auto_enroll",      :default => true
    t.boolean  "enable_collaboration",    :default => true
    t.boolean  "enable_one_signup",       :default => true
    t.string   "signup_token"
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
    t.integer  "section_id"
    t.integer  "task_id"
    t.string   "info_type"
    t.string   "obj_file_name"
    t.string   "obj_content_type"
    t.integer  "obj_file_size"
    t.datetime "obj_updated_at"
  end

  add_index "info_resources", ["path_id"], :name => "index_info_resources_on_path_id"

  create_table "leaderboards", :force => true do |t|
    t.integer  "user_id"
    t.integer  "completed_tasks", :default => 0
    t.integer  "score",           :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "category_id"
    t.integer  "path_id"
    t.integer  "section_id"
  end

  create_table "paths", :force => true do |t|
    t.string   "name"
    t.text     "description",            :default => ""
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "company_id"
    t.string   "image_url"
    t.boolean  "is_public",              :default => false
    t.integer  "purchased_path_id"
    t.boolean  "is_published",           :default => false
    t.boolean  "is_purchaseable",        :default => false
    t.integer  "owner_id"
    t.integer  "category_id",            :default => 0
    t.boolean  "enable_section_display", :default => true
    t.integer  "default_timer",          :default => 30
  end

  add_index "paths", ["user_id"], :name => "index_modules_on_user_id"

  create_table "phrase_pairings", :force => true do |t|
    t.integer  "phrase_id"
    t.integer  "paired_phrase_id"
    t.integer  "strength",         :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "phrase_pairings", ["phrase_id"], :name => "index_phrase_pairings_on_phrase_id"

  create_table "phrases", :force => true do |t|
    t.string   "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "phrases", ["content"], :name => "index_phrases_on_content", :unique => true

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
    t.text     "instructions"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "owner_id"
    t.boolean  "is_published",   :default => false
    t.string   "image_url"
    t.string   "content_type"
    t.text     "hidden_content"
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
    t.integer  "position"
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
