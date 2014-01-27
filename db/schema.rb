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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140127180411) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "answers", force: true do |t|
    t.integer  "task_id"
    t.text     "content"
    t.boolean  "is_correct",   default: false
    t.integer  "answer_count", default: 0
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  add_index "answers", ["task_id"], name: "index_answers_on_task_id", using: :btree

  create_table "collaborations", force: true do |t|
    t.integer  "path_id"
    t.integer  "user_id"
    t.integer  "granting_user_id"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  create_table "comments", force: true do |t|
    t.integer  "user_id"
    t.integer  "owner_id"
    t.text     "content"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.string   "owner_type"
    t.boolean  "is_reviewed", default: false
    t.boolean  "is_locked",   default: false
    t.datetime "reviewed_at"
    t.datetime "locked_at"
  end

  create_table "completed_tasks", force: true do |t|
    t.integer  "user_id"
    t.integer  "task_id"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.integer  "status_id",           default: 0
    t.integer  "points_awarded"
    t.string   "answer"
    t.integer  "submitted_answer_id"
    t.integer  "answer_id"
    t.boolean  "is_private",          default: false
    t.boolean  "is_restricted",       default: false
    t.integer  "enrollment_id"
    t.integer  "session_id"
    t.datetime "deleted_at"
    t.datetime "graded_at"
  end

  add_index "completed_tasks", ["submitted_answer_id"], name: "index_completed_tasks_on_submitted_answer_id", using: :btree
  add_index "completed_tasks", ["user_id", "task_id"], name: "index_completed_tasks_on_user_id_and_task_id", using: :btree

  create_table "contacts", force: true do |t|
    t.integer  "user_id"
    t.integer  "owner_id"
    t.datetime "purchased_at"
    t.datetime "paid_at"
    t.datetime "contacted_at"
    t.datetime "responded_at"
    t.text     "response"
    t.integer  "response_status", default: 0
    t.decimal  "amount_paid"
  end

  create_table "custom_styles", force: true do |t|
    t.integer  "owner_id"
    t.text     "styles"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.integer  "mode",       default: 0
    t.string   "owner_type"
  end

  create_table "enrollments", force: true do |t|
    t.integer  "user_id"
    t.integer  "path_id"
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.integer  "total_points",             default: 0
    t.boolean  "contribution_unlocked",    default: false
    t.datetime "contribution_unlocked_at"
    t.integer  "highest_rank",             default: 0
    t.integer  "longest_streak",           default: 0
    t.integer  "metascore",                default: 0
    t.integer  "metapercentile",           default: 0
    t.integer  "evaluation_id"
    t.datetime "private_at"
  end

  add_index "enrollments", ["path_id"], name: "index_enrollments_on_path_id", using: :btree
  add_index "enrollments", ["user_id", "path_id"], name: "index_enrollments_on_user_id_and_path_id", using: :btree
  add_index "enrollments", ["user_id"], name: "index_enrollments_on_user_id", using: :btree

  create_table "evaluation_enrollments", force: true do |t|
    t.integer  "evaluation_id"
    t.integer  "user_id"
    t.datetime "submitted_at"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.datetime "archived_at"
    t.datetime "favorited_at"
  end

  create_table "evaluation_paths", force: true do |t|
    t.integer  "evaluation_id"
    t.integer  "path_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "evaluations", force: true do |t|
    t.string   "title"
    t.string   "company"
    t.string   "link"
    t.string   "permalink"
    t.integer  "user_id"
    t.integer  "group_id"
    t.datetime "closed_at"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.datetime "published_at"
  end

  add_index "evaluations", ["permalink"], name: "index_evaluations_on_permalink", unique: true, using: :btree

  create_table "group_users", force: true do |t|
    t.integer  "group_id"
    t.integer  "user_id"
    t.boolean  "is_admin",   default: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.boolean  "hidden",     default: false
  end

  create_table "groups", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.text     "image_url"
    t.string   "permalink"
    t.string   "website"
    t.string   "city"
    t.string   "state"
    t.string   "country"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.string   "token"
    t.string   "plan_type",      default: "0"
    t.boolean  "is_private",     default: true
    t.string   "stripe_token"
    t.datetime "closed_at"
    t.text     "closed_reason"
    t.datetime "api_enabled_at"
  end

  create_table "ideas", force: true do |t|
    t.integer  "creator_id"
    t.string   "title"
    t.text     "description"
    t.string   "status"
    t.integer  "vote_count",  default: 0
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.integer  "idea_type",   default: 0
  end

  create_table "notification_settings", force: true do |t|
    t.integer  "user_id"
    t.boolean  "powers",      default: true
    t.boolean  "weekly",      default: true
    t.boolean  "interaction", default: true
    t.boolean  "inactive",    default: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_index "notification_settings", ["user_id"], name: "index_notification_settings_on_user_id", using: :btree

  create_table "path_personas", force: true do |t|
    t.integer "path_id"
    t.integer "persona_id"
  end

  add_index "path_personas", ["path_id", "persona_id"], name: "index_path_personas_on_path_id_and_persona_id", using: :btree

  create_table "paths", force: true do |t|
    t.string   "name"
    t.text     "description",                default: ""
    t.integer  "user_id"
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.string   "image_url"
    t.boolean  "is_public",                  default: false
    t.boolean  "is_published",               default: false
    t.boolean  "is_approved",                default: false
    t.string   "excluded_from_leaderboards"
    t.boolean  "is_locked",                  default: false
    t.string   "tags"
    t.boolean  "enable_voting",              default: false
    t.string   "permalink"
    t.datetime "approved_at"
    t.datetime "published_at"
    t.datetime "public_at"
    t.datetime "promoted_at"
    t.text     "template"
    t.integer  "tasks_attempted"
    t.float    "percent_correct"
    t.float    "correct_points"
    t.integer  "group_id"
    t.datetime "professional_at"
    t.integer  "input_type",                 default: 1
  end

  add_index "paths", ["permalink"], name: "index_paths_on_permalink", using: :btree
  add_index "paths", ["user_id"], name: "index_modules_on_user_id", using: :btree

  create_table "personas", force: true do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "points"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.string   "image_url"
    t.integer  "parent_id"
    t.integer  "unlock_threshold"
    t.boolean  "is_locked",        default: true
    t.datetime "locked_at"
  end

  create_table "phrase_pairings", force: true do |t|
    t.integer  "phrase_id"
    t.integer  "paired_phrase_id"
    t.integer  "strength",         default: 0
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  add_index "phrase_pairings", ["phrase_id"], name: "index_phrase_pairings_on_phrase_id", using: :btree

  create_table "phrases", force: true do |t|
    t.string   "content"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.string   "original_content"
  end

  add_index "phrases", ["content"], name: "index_phrases_on_content", unique: true, using: :btree

  create_table "sections", force: true do |t|
    t.integer  "path_id"
    t.string   "name"
    t.text     "instructions"
    t.integer  "position"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.boolean  "is_published",     default: false
    t.integer  "points_to_unlock", default: 0
    t.datetime "published_at"
  end

  add_index "sections", ["path_id"], name: "index_sections_on_path_id", using: :btree

  create_table "sent_emails", force: true do |t|
    t.text     "content"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "stored_resources", force: true do |t|
    t.string   "description"
    t.text     "link"
    t.integer  "path_id"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
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

  add_index "stored_resources", ["owner_id", "owner_type"], name: "index_stored_resources_on_owner_id_and_owner_name", using: :btree
  add_index "stored_resources", ["path_id"], name: "index_info_resources_on_path_id", using: :btree

  create_table "submitted_answers", force: true do |t|
    t.text     "content"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.integer  "total_votes",    default: 0
    t.integer  "task_id"
    t.boolean  "is_reviewed",    default: false
    t.boolean  "is_locked",      default: false
    t.datetime "reviewed_at"
    t.datetime "locked_at"
    t.text     "caption"
    t.text     "url"
    t.text     "title"
    t.text     "description"
    t.text     "image_url"
    t.text     "site_name"
    t.text     "preview"
    t.text     "preview_errors"
    t.boolean  "has_comments",   default: false
    t.datetime "promoted_at"
    t.integer  "total_comments", default: 0
  end

  add_index "submitted_answers", ["task_id"], name: "index_submitted_answers_on_task_id", using: :btree

  create_table "subscriptions", force: true do |t|
    t.integer  "followed_id"
    t.integer  "follower_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "subscriptions", ["followed_id", "follower_id"], name: "index_subscriptions_on_followed_id_and_follower_id", unique: true, using: :btree

  create_table "task_issues", force: true do |t|
    t.integer  "task_id"
    t.integer  "user_id"
    t.integer  "issue_type"
    t.boolean  "resolved",    default: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.datetime "resolved_at"
  end

  create_table "tasks", force: true do |t|
    t.text     "question"
    t.text     "resource"
    t.integer  "points"
    t.integer  "section_id"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.integer  "correct_answer",     default: 1
    t.integer  "position",           default: 0
    t.integer  "answer_type",        default: 2
    t.integer  "answer_sub_type"
    t.boolean  "disable_time_limit", default: false
    t.integer  "time_limit",         default: 30
    t.integer  "creator_id"
    t.boolean  "is_locked",          default: false
    t.boolean  "is_reviewed",        default: false
    t.datetime "reviewed_at"
    t.datetime "locked_at"
    t.text     "template"
    t.text     "resource_title"
    t.datetime "archived_at"
    t.text     "quoted_text"
    t.integer  "topic_id"
    t.integer  "path_id"
    t.decimal  "difficulty",         default: 0.0
    t.datetime "professional_at"
  end

  add_index "tasks", ["section_id"], name: "index_tasks_on_path_id", using: :btree

  create_table "topics", force: true do |t|
    t.integer  "path_id"
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_auths", force: true do |t|
    t.integer  "user_id"
    t.string   "provider"
    t.string   "uid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "user_auths", ["user_id"], name: "index_user_auths_on_user_id", using: :btree

  create_table "user_events", force: true do |t|
    t.integer  "user_id"
    t.text     "content"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.boolean  "is_read",     default: false
    t.string   "link"
    t.integer  "actioner_id"
    t.string   "image_link"
    t.datetime "read_at"
    t.integer  "path_id"
    t.string   "action_text"
  end

  add_index "user_events", ["user_id"], name: "index_user_events_on_user_id", using: :btree

  create_table "user_personas", force: true do |t|
    t.integer  "persona_id"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "level"
  end

  add_index "user_personas", ["user_id", "persona_id"], name: "index_user_personas_on_user_id_and_persona_id", using: :btree

  create_table "user_roles", force: true do |t|
    t.string   "name"
    t.boolean  "enable_administration",   default: false
    t.boolean  "enable_content_creation", default: false
    t.string   "signup_token"
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
  end

  create_table "user_transactions", force: true do |t|
    t.integer  "user_id"
    t.integer  "reward_id"
    t.integer  "task_id"
    t.float    "amount"
    t.integer  "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "path_id"
    t.integer  "owner_id"
    t.string   "owner_type"
  end

  add_index "user_transactions", ["owner_id", "owner_type", "user_id"], name: "index_user_transactions_on_owner_id_and_owner_type_and_user_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at",                                                           null: false
    t.datetime "updated_at",                                                           null: false
    t.string   "encrypted_password"
    t.string   "salt"
    t.boolean  "admin",                                                default: false
    t.integer  "earned_points",                                        default: 0
    t.integer  "spent_points",                                         default: 0
    t.string   "image_url"
    t.string   "signup_token"
    t.integer  "user_role_id"
    t.string   "username"
    t.boolean  "is_fake_user",                                         default: false
    t.boolean  "is_test_user",                                         default: false
    t.datetime "login_at"
    t.datetime "logout_at"
    t.string   "description"
    t.string   "education"
    t.string   "company_name"
    t.string   "title"
    t.string   "location"
    t.string   "link"
    t.boolean  "is_locked",                                            default: false
    t.string   "large_image_url"
    t.text     "viewed_help"
    t.datetime "locked_at"
    t.integer  "emails_today",                                         default: 0
    t.datetime "last_email_sent_at"
    t.string   "city"
    t.string   "state"
    t.string   "country"
    t.boolean  "seen_opportunities"
    t.boolean  "wants_full_time"
    t.boolean  "wants_part_time"
    t.boolean  "wants_internship"
    t.boolean  "wants_university"
    t.decimal  "latitude",                    precision: 10, scale: 6
    t.decimal  "longitude",                   precision: 10, scale: 6
    t.boolean  "enable_administration",                                default: false
    t.datetime "content_creation_enabled_at"
    t.datetime "private_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["username"], name: "index_users_on_username", using: :btree

  create_table "vanity_conversions", force: true do |t|
    t.integer "vanity_experiment_id"
    t.integer "alternative"
    t.integer "conversions"
  end

  add_index "vanity_conversions", ["vanity_experiment_id", "alternative"], name: "by_experiment_id_and_alternative", using: :btree

  create_table "vanity_experiments", force: true do |t|
    t.string   "experiment_id"
    t.integer  "outcome"
    t.datetime "created_at"
    t.datetime "completed_at"
  end

  add_index "vanity_experiments", ["experiment_id"], name: "index_vanity_experiments_on_experiment_id", using: :btree

  create_table "vanity_metric_values", force: true do |t|
    t.integer "vanity_metric_id"
    t.integer "index"
    t.integer "value"
    t.string  "date"
  end

  add_index "vanity_metric_values", ["vanity_metric_id"], name: "index_vanity_metric_values_on_vanity_metric_id", using: :btree

  create_table "vanity_metrics", force: true do |t|
    t.string   "metric_id"
    t.datetime "updated_at"
  end

  add_index "vanity_metrics", ["metric_id"], name: "index_vanity_metrics_on_metric_id", using: :btree

  create_table "vanity_participants", force: true do |t|
    t.string  "experiment_id"
    t.string  "identity"
    t.integer "shown"
    t.integer "seen"
    t.integer "converted"
  end

  add_index "vanity_participants", ["experiment_id", "converted"], name: "by_experiment_id_and_converted", using: :btree
  add_index "vanity_participants", ["experiment_id", "identity"], name: "by_experiment_id_and_identity", using: :btree
  add_index "vanity_participants", ["experiment_id", "seen"], name: "by_experiment_id_and_seen", using: :btree
  add_index "vanity_participants", ["experiment_id", "shown"], name: "by_experiment_id_and_shown", using: :btree
  add_index "vanity_participants", ["experiment_id"], name: "index_vanity_participants_on_experiment_id", using: :btree

  create_table "visits", force: true do |t|
    t.integer  "user_id"
    t.integer  "visitor_id"
    t.text     "request_url"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.string   "external_id"
    t.text     "referral_url"
    t.string   "user_agent"
    t.string   "remote_ip"
  end

  add_index "visits", ["external_id"], name: "index_visits_on_external_id", unique: true, using: :btree

  create_table "votes", force: true do |t|
    t.integer  "owner_id"
    t.integer  "user_id"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.string   "owner_type", default: "SubmittedAnswer"
  end

  add_index "votes", ["owner_id", "owner_type", "user_id"], name: "index_votes_on_owner_id_and_owner_type_and_user_id", unique: true, using: :btree
  add_index "votes", ["user_id", "owner_id"], name: "index_votes_on_user_id_and_submitted_answer_id", using: :btree
  add_index "votes", ["user_id"], name: "index_votes_on_user_id", using: :btree

end
