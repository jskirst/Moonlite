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

ActiveRecord::Schema.define(:version => 20120617221401) do

  create_table "achievements", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.string   "criteria"
    t.integer  "points"
    t.datetime "created_at"
    t.datetime "updated_at"
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

  create_table "collaborations", :force => true do |t|
    t.integer  "path_id"
    t.integer  "user_id"
    t.integer  "granting_user_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
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
    t.boolean  "enable_company_store",         :default => true
    t.boolean  "enable_leaderboard",           :default => true
    t.boolean  "enable_dashboard",             :default => true
    t.boolean  "enable_tour",                  :default => true
    t.boolean  "enable_comments",              :default => true
    t.boolean  "enable_feedback",              :default => true
    t.boolean  "enable_news",                  :default => true
    t.boolean  "enable_achievements",          :default => true
    t.boolean  "enable_recommendations",       :default => true
    t.boolean  "enable_printer_friendly",      :default => true
    t.boolean  "enable_browsing",              :default => true
    t.boolean  "enable_user_creation",         :default => true
    t.boolean  "enable_auto_enroll",           :default => true
    t.boolean  "enable_collaboration",         :default => true
    t.boolean  "enable_one_signup",            :default => true
    t.string   "signup_token"
    t.string   "default_profile_picture_link"
    t.boolean  "enable_auto_generate",         :default => false
    t.integer  "user_role_id"
    t.integer  "seat_limit",                   :default => 50
    t.string   "name_for_paths",               :default => "certification"
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
  end

  create_table "completed_tasks", :force => true do |t|
    t.integer  "user_id"
    t.integer  "task_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "status_id",           :default => 0
    t.datetime "quiz_session"
    t.integer  "points_awarded"
    t.string   "answer"
    t.integer  "submitted_answer_id"
  end

  create_table "custom_styles", :force => true do |t|
    t.integer  "company_id"
    t.text     "styles"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
    t.integer  "mode",       :default => 0
  end

  create_table "enrollments", :force => true do |t|
    t.integer  "user_id"
    t.integer  "path_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "total_points", :default => 0
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

  create_table "path_user_roles", :force => true do |t|
    t.integer  "user_role_id"
    t.integer  "path_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "path_user_roles", ["user_role_id", "path_id"], :name => "index_path_user_roles_on_user_role_id_and_path_id"

  create_table "paths", :force => true do |t|
    t.string   "name"
    t.string   "description",                :default => ""
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "company_id"
    t.string   "image_url"
    t.boolean  "is_public",                  :default => false
    t.integer  "purchased_path_id"
    t.boolean  "is_published",               :default => false
    t.boolean  "is_purchaseable",            :default => false
    t.integer  "category_id",                :default => 0
    t.boolean  "enable_section_display",     :default => false
    t.integer  "default_timer",              :default => 30
    t.string   "excluded_from_leaderboards"
    t.boolean  "enable_nonlinear_sections",  :default => false
    t.boolean  "is_locked",                  :default => false
    t.boolean  "enable_retakes",             :default => true
    t.string   "game_type",                  :default => "basic"
    t.string   "tags"
    t.boolean  "enable_voting",              :default => false
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
    t.string   "original_content"
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
  end

  create_table "sections", :force => true do |t|
    t.integer  "path_id"
    t.string   "name"
    t.text     "instructions"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_published",        :default => false
    t.string   "image_url"
    t.string   "content_type"
    t.text     "hidden_content"
    t.boolean  "skip_content",        :default => false
    t.boolean  "enable_skip_content", :default => false
  end

  create_table "submitted_answers", :force => true do |t|
    t.string   "content"
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
    t.integer  "total_votes", :default => 0
    t.integer  "task_id"
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
    t.integer  "correct_answer",  :default => 1
    t.integer  "position"
    t.integer  "answer_type",     :default => 2
    t.integer  "answer_sub_type"
  end

  add_index "tasks", ["section_id"], :name => "index_tasks_on_path_id"

  create_table "usage_reports", :force => true do |t|
    t.integer  "company_id"
    t.string   "name"
    t.string   "report_file_name"
    t.string   "report_content_type"
    t.integer  "report_file_size"
    t.datetime "report_updated_at"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  create_table "user_achievements", :force => true do |t|
    t.integer  "achievement_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_auths", :force => true do |t|
    t.integer  "user_id"
    t.string   "provider"
    t.string   "uid"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "user_events", :force => true do |t|
    t.integer  "user_id"
    t.integer  "path_id"
    t.string   "content"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "user_roles", :force => true do |t|
    t.string   "name"
    t.integer  "company_id"
    t.boolean  "enable_administration",   :default => false
    t.boolean  "enable_leaderboard",      :default => false
    t.boolean  "enable_dashboard",        :default => false
    t.boolean  "enable_tour",             :default => false
    t.boolean  "enable_rewards",          :default => false
    t.boolean  "enable_comments",         :default => false
    t.boolean  "enable_feedback",         :default => false
    t.boolean  "enable_news",             :default => false
    t.boolean  "enable_achievements",     :default => false
    t.boolean  "enable_recommendations",  :default => false
    t.boolean  "enable_printer_friendly", :default => false
    t.boolean  "enable_browsing",         :default => false
    t.boolean  "enable_user_creation",    :default => false
    t.boolean  "enable_auto_enroll",      :default => false
    t.boolean  "enable_collaboration",    :default => false
    t.boolean  "enable_one_signup",       :default => false
    t.boolean  "enable_company_store",    :default => false
    t.boolean  "enable_auto_generate",    :default => false
    t.string   "signup_token"
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
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
    t.string   "signup_token"
    t.integer  "company_id"
    t.boolean  "company_admin",      :default => false
    t.integer  "user_role_id"
    t.string   "catch_phrase"
    t.boolean  "is_fake_user",       :default => false
    t.string   "provider"
    t.string   "uid"
    t.boolean  "is_test_user",       :default => false
    t.boolean  "is_anonymous",       :default => false
    t.datetime "login_at"
    t.datetime "logout_at"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true

  create_table "vanity_conversions", :force => true do |t|
    t.integer "vanity_experiment_id"
    t.integer "alternative"
    t.integer "conversions"
  end

  add_index "vanity_conversions", ["vanity_experiment_id", "alternative"], :name => "by_experiment_id_and_alternative"

  create_table "vanity_experiments", :force => true do |t|
    t.string   "experiment_id"
    t.integer  "outcome"
    t.datetime "created_at"
    t.datetime "completed_at"
  end

  add_index "vanity_experiments", ["experiment_id"], :name => "index_vanity_experiments_on_experiment_id"

  create_table "vanity_metric_values", :force => true do |t|
    t.integer "vanity_metric_id"
    t.integer "index"
    t.integer "value"
    t.string  "date"
  end

  add_index "vanity_metric_values", ["vanity_metric_id"], :name => "index_vanity_metric_values_on_vanity_metric_id"

  create_table "vanity_metrics", :force => true do |t|
    t.string   "metric_id"
    t.datetime "updated_at"
  end

  add_index "vanity_metrics", ["metric_id"], :name => "index_vanity_metrics_on_metric_id"

  create_table "vanity_participants", :force => true do |t|
    t.string  "experiment_id"
    t.string  "identity"
    t.integer "shown"
    t.integer "seen"
    t.integer "converted"
  end

  add_index "vanity_participants", ["experiment_id", "converted"], :name => "by_experiment_id_and_converted"
  add_index "vanity_participants", ["experiment_id", "identity"], :name => "by_experiment_id_and_identity"
  add_index "vanity_participants", ["experiment_id", "seen"], :name => "by_experiment_id_and_seen"
  add_index "vanity_participants", ["experiment_id", "shown"], :name => "by_experiment_id_and_shown"
  add_index "vanity_participants", ["experiment_id"], :name => "index_vanity_participants_on_experiment_id"

end
