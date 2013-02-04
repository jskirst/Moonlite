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

ActiveRecord::Schema.define(:version => 20130201165414) do

  create_table "answers", :force => true do |t|
    t.integer  "task_id"
    t.string   "content"
    t.boolean  "is_correct",   :default => false
    t.integer  "answer_count", :default => 0
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
  end

  add_index "answers", ["task_id"], :name => "index_answers_on_task_id"

  create_table "categories", :force => true do |t|
    t.integer  "company_id"
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
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
    t.integer  "owner_id"
    t.string   "content"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
    t.string   "owner_type"
    t.boolean  "is_reviewed", :default => false
    t.boolean  "is_locked",   :default => false
    t.datetime "reviewed_at"
    t.datetime "locked_at"
  end

  create_table "companies", :force => true do |t|
    t.string   "name"
    t.datetime "created_at",                                                :null => false
    t.datetime "updated_at",                                                :null => false
    t.boolean  "enable_news",                  :default => true
    t.boolean  "enable_auto_enroll",           :default => true
    t.string   "default_profile_picture_link"
    t.integer  "user_role_id"
    t.integer  "seat_limit",                   :default => 50
    t.string   "name_for_paths",               :default => "certification"
    t.boolean  "enable_traditional_explore",   :default => true
    t.string   "home_title"
    t.string   "home_subtitle"
    t.string   "home_paragraph"
    t.string   "big_logo_link"
    t.string   "small_logo_link"
    t.string   "referrer_url"
    t.boolean  "enable_custom_landing",        :default => false
    t.string   "custom_email_from"
  end

  create_table "company_users", :force => true do |t|
    t.string   "email"
    t.integer  "user_id"
    t.integer  "company_id"
    t.string   "token1"
    t.string   "token2"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.boolean  "is_admin"
  end

  create_table "completed_tasks", :force => true do |t|
    t.integer  "user_id"
    t.integer  "task_id"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.integer  "status_id",           :default => 0
    t.integer  "points_awarded"
    t.string   "answer"
    t.integer  "submitted_answer_id"
    t.integer  "answer_id"
    t.boolean  "is_private",          :default => false
    t.boolean  "is_restricted",       :default => false
  end

  add_index "completed_tasks", ["submitted_answer_id"], :name => "index_completed_tasks_on_submitted_answer_id"
  add_index "completed_tasks", ["user_id", "task_id"], :name => "index_completed_tasks_on_user_id_and_task_id"

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
    t.datetime "created_at",                                  :null => false
    t.datetime "updated_at",                                  :null => false
    t.integer  "total_points",             :default => 0
    t.boolean  "contribution_unlocked",    :default => false
    t.datetime "contribution_unlocked_at"
  end

  add_index "enrollments", ["path_id"], :name => "index_enrollments_on_path_id"
  add_index "enrollments", ["user_id", "path_id"], :name => "index_enrollments_on_user_id_and_path_id"
  add_index "enrollments", ["user_id"], :name => "index_enrollments_on_user_id"

  create_table "leaderboards", :force => true do |t|
    t.integer  "user_id"
    t.integer  "completed_tasks", :default => 0
    t.integer  "score",           :default => 0
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
    t.integer  "category_id"
    t.integer  "path_id"
    t.integer  "section_id"
  end

  create_table "notification_settings", :force => true do |t|
    t.integer  "user_id"
    t.boolean  "powers",      :default => true
    t.boolean  "weekly",      :default => true
    t.boolean  "interaction", :default => true
    t.boolean  "inactive",    :default => false
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
  end

  add_index "notification_settings", ["user_id"], :name => "index_notification_settings_on_user_id"

  create_table "path_personas", :force => true do |t|
    t.integer "path_id"
    t.integer "persona_id"
  end

  add_index "path_personas", ["path_id", "persona_id"], :name => "index_path_personas_on_path_id_and_persona_id"

  create_table "path_user_roles", :force => true do |t|
    t.integer  "user_role_id"
    t.integer  "path_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "path_user_roles", ["user_role_id", "path_id"], :name => "index_path_user_roles_on_user_role_id_and_path_id"

  create_table "paths", :force => true do |t|
    t.string   "name"
    t.text     "description",                :default => ""
    t.integer  "user_id"
    t.datetime "created_at",                                    :null => false
    t.datetime "updated_at",                                    :null => false
    t.integer  "company_id"
    t.string   "image_url"
    t.boolean  "is_public",                  :default => false
    t.boolean  "is_published",               :default => false
    t.boolean  "is_approved",                :default => false
    t.integer  "category_id",                :default => 0
    t.string   "excluded_from_leaderboards"
    t.boolean  "is_locked",                  :default => false
    t.string   "tags"
    t.boolean  "enable_voting",              :default => false
    t.string   "permalink"
    t.datetime "approved_at"
    t.datetime "published_at"
    t.datetime "public_at"
  end

  add_index "paths", ["permalink"], :name => "index_paths_on_permalink"
  add_index "paths", ["user_id"], :name => "index_modules_on_user_id"

  create_table "personas", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "points"
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
    t.string   "image_url"
    t.integer  "company_id"
    t.integer  "parent_id"
    t.integer  "unlock_threshold"
    t.boolean  "is_locked",        :default => true
    t.datetime "locked_at"
  end

  create_table "phrase_pairings", :force => true do |t|
    t.integer  "phrase_id"
    t.integer  "paired_phrase_id"
    t.integer  "strength",         :default => 0
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
  end

  add_index "phrase_pairings", ["phrase_id"], :name => "index_phrase_pairings_on_phrase_id"

  create_table "phrases", :force => true do |t|
    t.string   "content"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.string   "original_content"
  end

  add_index "phrases", ["content"], :name => "index_phrases_on_content", :unique => true

  create_table "rewards", :force => true do |t|
    t.integer  "company_id"
    t.string   "name"
    t.string   "description"
    t.integer  "points"
    t.string   "image_url"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "sections", :force => true do |t|
    t.integer  "path_id"
    t.string   "name"
    t.text     "instructions"
    t.integer  "position"
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
    t.boolean  "is_published",     :default => false
    t.integer  "points_to_unlock", :default => 0
    t.datetime "published_at"
  end

  add_index "sections", ["path_id"], :name => "index_sections_on_path_id"

  create_table "sent_emails", :force => true do |t|
    t.text     "content"
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "stored_resources", :force => true do |t|
    t.string   "description"
    t.string   "link"
    t.integer  "path_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.integer  "section_id"
    t.integer  "task_id"
    t.string   "info_type"
    t.string   "obj_file_name"
    t.string   "obj_content_type"
    t.integer  "obj_file_size"
    t.datetime "obj_updated_at"
    t.integer  "owner_id"
    t.string   "owner_type"
  end

  add_index "stored_resources", ["owner_id", "owner_type"], :name => "index_stored_resources_on_owner_id_and_owner_name"
  add_index "stored_resources", ["path_id"], :name => "index_info_resources_on_path_id"

  create_table "submitted_answers", :force => true do |t|
    t.text     "content"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
    t.integer  "total_votes", :default => 0
    t.integer  "task_id"
    t.boolean  "is_reviewed", :default => false
    t.boolean  "is_locked",   :default => false
    t.datetime "reviewed_at"
    t.datetime "locked_at"
  end

  add_index "submitted_answers", ["task_id"], :name => "index_submitted_answers_on_task_id"

  create_table "task_issues", :force => true do |t|
    t.integer  "task_id"
    t.integer  "user_id"
    t.integer  "issue_type"
    t.boolean  "resolved",    :default => false
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
    t.datetime "resolved_at"
  end

  create_table "tasks", :force => true do |t|
    t.text     "question"
    t.string   "resource"
    t.integer  "points"
    t.integer  "section_id"
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
    t.integer  "correct_answer",     :default => 1
    t.integer  "position"
    t.integer  "answer_type",        :default => 2
    t.integer  "answer_sub_type"
    t.boolean  "disable_time_limit", :default => false
    t.integer  "time_limit",         :default => 30
    t.integer  "creator_id"
    t.boolean  "is_locked",          :default => false
    t.boolean  "is_reviewed",        :default => false
    t.datetime "reviewed_at"
    t.datetime "locked_at"
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

  create_table "user_auths", :force => true do |t|
    t.integer  "user_id"
    t.string   "provider"
    t.string   "uid"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "user_auths", ["user_id"], :name => "index_user_auths_on_user_id"

  create_table "user_events", :force => true do |t|
    t.integer  "user_id"
    t.string   "content"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
    t.boolean  "is_read",     :default => false
    t.string   "link"
    t.integer  "actioner_id"
    t.string   "image_link"
    t.datetime "read_at"
  end

  add_index "user_events", ["user_id"], :name => "index_user_events_on_user_id"

  create_table "user_personas", :force => true do |t|
    t.integer  "persona_id"
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "level"
  end

  add_index "user_personas", ["user_id", "persona_id"], :name => "index_user_personas_on_user_id_and_persona_id"

  create_table "user_roles", :force => true do |t|
    t.string   "name"
    t.integer  "company_id"
    t.boolean  "enable_administration",   :default => false
    t.boolean  "enable_content_creation", :default => false
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
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "path_id"
    t.integer  "owner_id"
    t.string   "owner_type"
  end

  add_index "user_transactions", ["owner_id", "owner_type", "user_id"], :name => "index_user_transactions_on_owner_id_and_owner_type_and_user_id"

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
    t.string   "encrypted_password"
    t.string   "salt"
    t.boolean  "admin",              :default => false
    t.integer  "earned_points",      :default => 0
    t.integer  "spent_points",       :default => 0
    t.string   "image_url"
    t.string   "signup_token"
    t.integer  "company_id"
    t.integer  "user_role_id"
    t.string   "username"
    t.boolean  "is_fake_user",       :default => false
    t.boolean  "is_test_user",       :default => false
    t.datetime "login_at"
    t.datetime "logout_at"
    t.string   "description"
    t.string   "education"
    t.string   "company_name"
    t.string   "title"
    t.string   "location"
    t.string   "link"
    t.boolean  "is_locked",          :default => false
    t.string   "large_image_url"
    t.text     "viewed_help"
    t.datetime "locked_at"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["username"], :name => "index_users_on_username"

  create_table "votes", :force => true do |t|
    t.integer  "submitted_answer_id"
    t.integer  "user_id"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  add_index "votes", ["user_id", "submitted_answer_id"], :name => "index_votes_on_user_id_and_submitted_answer_id"
  add_index "votes", ["user_id"], :name => "index_votes_on_user_id"

end
