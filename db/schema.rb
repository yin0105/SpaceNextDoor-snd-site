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

ActiveRecord::Schema.define(version: 2021_02_15_070925) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_admin_comments", id: :serial, force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_id", null: false
    t.string "resource_type", null: false
    t.string "author_type"
    t.integer "author_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id"
  end

  create_table "addresses", id: :serial, force: :cascade do |t|
    t.string "addressable_type", limit: 32
    t.integer "addressable_id"
    t.string "country", limit: 8
    t.string "city", limit: 16
    t.string "area", limit: 16
    t.string "street_address"
    t.string "unit"
    t.float "latitude"
    t.float "longitude"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "postal_code", limit: 16
    t.index ["addressable_id"], name: "index_addresses_on_addressable_id"
    t.index ["addressable_type"], name: "index_addresses_on_addressable_type"
    t.index ["area"], name: "index_addresses_on_area"
    t.index ["city"], name: "index_addresses_on_city"
    t.index ["country"], name: "index_addresses_on_country"
    t.index ["latitude", "longitude"], name: "index_addresses_on_latitude_and_longitude"
  end

  create_table "admin_action_logs", force: :cascade do |t|
    t.bigint "admin_id"
    t.integer "target_id"
    t.string "target_type"
    t.string "event"
    t.integer "status", default: 0
    t.string "request_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["admin_id"], name: "index_admin_action_logs_on_admin_id"
  end

  create_table "admins", id: :serial, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "failed_attempts", default: 0
    t.string "unlock_token"
    t.datetime "locked_at"
    t.string "type", default: "Admin::General"
    t.index ["email"], name: "index_admins_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_admins_on_unlock_token", unique: true
  end

  create_table "bank_accounts", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "country", limit: 4, null: false
    t.string "bank_code", limit: 6, null: false
    t.string "account_name", limit: 32, null: false
    t.string "account_number", limit: 64, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "bank_name", limit: 50
    t.string "branch_code", limit: 6
    t.index ["user_id"], name: "index_bank_accounts_on_user_id"
  end

  create_table "booking_slots", id: :serial, force: :cascade do |t|
    t.integer "space_id"
    t.date "date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "status", default: 0
    t.index ["space_id"], name: "index_booking_slots_on_space_id"
    t.index ["status"], name: "index_booking_slots_on_status"
  end

  create_table "channels", id: :serial, force: :cascade do |t|
    t.integer "guest_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "space_id"
    t.integer "host_id"
    t.index ["guest_id"], name: "index_channels_on_guest_id"
    t.index ["host_id"], name: "index_channels_on_host_id"
    t.index ["space_id"], name: "index_channels_on_space_id"
  end

  create_table "contacts", force: :cascade do |t|
    t.bigint "user_id"
    t.integer "type"
    t.string "name"
    t.string "email"
    t.string "phone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_contacts_on_user_id"
  end

  create_table "double_entry_account_balances", id: :serial, force: :cascade do |t|
    t.string "account", limit: 31, null: false
    t.string "scope", limit: 23
    t.integer "balance", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account"], name: "index_account_balances_on_account"
    t.index ["scope", "account"], name: "index_account_balances_on_scope_and_account", unique: true
  end

  create_table "double_entry_line_aggregates", id: :serial, force: :cascade do |t|
    t.string "function", limit: 15, null: false
    t.string "account", limit: 31, null: false
    t.string "code", limit: 47
    t.string "scope", limit: 23
    t.integer "year"
    t.integer "month"
    t.integer "week"
    t.integer "day"
    t.integer "hour"
    t.integer "amount", null: false
    t.string "filter"
    t.string "range_type", limit: 15, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["function", "account", "code", "year", "month", "week", "day"], name: "line_aggregate_idx"
  end

  create_table "double_entry_line_checks", id: :serial, force: :cascade do |t|
    t.integer "last_line_id", null: false
    t.boolean "errors_found", null: false
    t.text "log"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "double_entry_line_metadata", id: :serial, force: :cascade do |t|
    t.integer "line_id", null: false
    t.string "key", limit: 48, null: false
    t.string "value", limit: 64, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["line_id", "key", "value"], name: "lines_meta_line_id_key_value_idx"
  end

  create_table "double_entry_lines", id: :serial, force: :cascade do |t|
    t.string "account", limit: 31, null: false
    t.string "scope", limit: 23
    t.string "code", limit: 47, null: false
    t.integer "amount", null: false
    t.integer "balance", null: false
    t.integer "partner_id"
    t.string "partner_account", limit: 31, null: false
    t.string "partner_scope", limit: 23
    t.integer "detail_id"
    t.string "detail_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account", "code", "created_at"], name: "lines_account_code_created_at_idx"
    t.index ["account", "created_at"], name: "lines_account_created_at_idx"
    t.index ["scope", "account", "created_at"], name: "lines_scope_account_created_at_idx"
    t.index ["scope", "account", "id"], name: "lines_scope_account_id_idx"
  end

  create_table "find_out_requests", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.string "phone"
    t.string "email", null: false
    t.string "location"
    t.datetime "start_at"
    t.datetime "end_at"
    t.text "description"
    t.integer "size", null: false
    t.boolean "accept_receive_updates", default: true
    t.integer "space_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "identity", default: 0, null: false
    t.string "address"
    t.string "postal_code", limit: 16
  end

  create_table "images", id: :serial, force: :cascade do |t|
    t.string "imageable_type"
    t.integer "imageable_id"
    t.string "image"
    t.string "secure_token"
    t.integer "width"
    t.integer "height"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "description"
    t.index ["imageable_type", "imageable_id"], name: "index_images_on_imageable_type_and_imageable_id"
    t.index ["secure_token"], name: "index_images_on_secure_token", unique: true
  end

  create_table "messages", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "channel_id"
    t.datetime "read_at"
    t.boolean "is_system", default: false
    t.index ["channel_id"], name: "index_messages_on_channel_id"
    t.index ["user_id"], name: "index_messages_on_user_id"
  end

  create_table "notifications", id: :serial, force: :cascade do |t|
    t.integer "admin_id"
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "title"
    t.integer "notify_type", default: 0
    t.index ["admin_id"], name: "index_notifications_on_admin_id"
  end

  create_table "orders", id: :serial, force: :cascade do |t|
    t.integer "type", default: 0, null: false
    t.integer "total_payment_cycle", default: 1, null: false
    t.integer "remain_payment_cycle", default: 1, null: false
    t.integer "host_id"
    t.integer "guest_id"
    t.integer "space_id"
    t.integer "status", null: false
    t.date "start_at"
    t.date "end_at"
    t.text "note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "cancelled_at"
    t.integer "price_cents", default: 0, null: false
    t.string "price_currency", default: "SGD", null: false
    t.integer "channel_id"
    t.integer "damage_fee_cents", default: 0, null: false
    t.string "damage_fee_currency", default: "SGD", null: false
    t.boolean "long_term", default: false
    t.date "long_term_cancelled_at"
    t.integer "discount_code"
    t.integer "premium_cents", default: 0, null: false
    t.string "premium_currency", default: "SGD", null: false
    t.boolean "insurance_enable", default: false
    t.string "insurance_type"
    t.boolean "insurance_lock", default: false
    t.integer "add_fee_cents", default: 0, null: false
    t.string "add_fee_currency", default: "SGD", null: false
    t.text "reasons_for_adjustment"
    t.date "long_term_start_at"
    t.integer "rent_payout_type", default: 2
    t.string "transform_long_lease_by"
    t.index ["channel_id"], name: "index_orders_on_channel_id"
    t.index ["guest_id"], name: "index_orders_on_guest_id"
    t.index ["host_id"], name: "index_orders_on_host_id"
    t.index ["long_term"], name: "index_orders_on_long_term"
    t.index ["space_id"], name: "index_orders_on_space_id"
    t.index ["status"], name: "index_orders_on_status"
    t.index ["type"], name: "index_orders_on_type"
  end

  create_table "payments", id: :serial, force: :cascade do |t|
    t.integer "order_id"
    t.integer "rent_cents", default: 0, null: false
    t.string "rent_currency", default: "SGD", null: false
    t.integer "payment_type", null: false
    t.string "transaction_id"
    t.integer "user_id"
    t.integer "status", default: 0
    t.datetime "service_start_at", null: false
    t.datetime "service_end_at", null: false
    t.integer "serial", default: 1
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "retry_count", default: 0
    t.integer "deposit_cents", default: 0, null: false
    t.string "deposit_currency", default: "SGD", null: false
    t.integer "guest_service_fee_cents", default: 0, null: false
    t.string "guest_service_fee_currency", default: "SGD", null: false
    t.integer "host_service_fee_cents", default: 0, null: false
    t.string "host_service_fee_currency", default: "SGD", null: false
    t.datetime "failed_at"
    t.datetime "resolved_at"
    t.string "identifier"
    t.text "error_message"
    t.integer "premium_cents", default: 0, null: false
    t.string "premium_currency", default: "SGD", null: false
    t.string "insurance_type"
    t.index ["failed_at", "status"], name: "index_payments_on_failed_at_and_status"
    t.index ["identifier"], name: "index_payments_on_identifier"
    t.index ["order_id"], name: "index_payments_on_order_id"
    t.index ["user_id"], name: "index_payments_on_user_id"
  end

  create_table "payouts", id: :serial, force: :cascade do |t|
    t.integer "payment_id"
    t.integer "user_id"
    t.integer "status"
    t.integer "type"
    t.integer "amount_cents", default: 0, null: false
    t.string "amount_currency", default: "SGD", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "start_at"
    t.datetime "end_at"
    t.datetime "actual_paid_at"
    t.index ["payment_id"], name: "index_payouts_on_payment_id"
    t.index ["user_id"], name: "index_payouts_on_user_id"
  end

  create_table "ratings", id: :serial, force: :cascade do |t|
    t.string "ratable_type"
    t.integer "ratable_id"
    t.float "rate"
    t.integer "user_id"
    t.integer "order_id"
    t.text "note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "rater_type"
    t.integer "status"
    t.index ["order_id"], name: "index_ratings_on_order_id"
    t.index ["ratable_type", "ratable_id"], name: "index_ratings_on_ratable_type_and_ratable_id"
    t.index ["user_id"], name: "index_ratings_on_user_id"
  end

  create_table "schedules", id: :serial, force: :cascade do |t|
    t.integer "schedulable_id"
    t.string "schedulable_type"
    t.string "event"
    t.integer "status"
    t.datetime "schedule_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["schedulable_id", "schedulable_type"], name: "index_schedules_on_schedulable_id_and_schedulable_type"
    t.index ["status", "schedule_at"], name: "index_schedules_on_status_and_schedule_at"
  end

  create_table "service_fees", id: :serial, force: :cascade do |t|
    t.float "host_rate"
    t.float "guest_rate"
    t.integer "order_id"
    t.index ["order_id"], name: "index_service_fees_on_order_id"
  end

  create_table "spaces", id: :serial, force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.integer "user_id"
    t.integer "status", default: 0
    t.boolean "govid_required", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "spaceable_type"
    t.integer "spaceable_id"
    t.integer "daily_price_cents", default: 0, null: false
    t.string "daily_price_currency", default: "SGD", null: false
    t.integer "minimum_rent_days"
    t.float "area", default: 0.0
    t.float "height"
    t.integer "property"
    t.integer "discount_code"
    t.boolean "auto_extend_slot", default: false
    t.boolean "insurance_enable", default: true
    t.text "reasons_for_disapproval"
    t.integer "rent_payout_type", default: 2
    t.boolean "featured", default: false
    t.index ["property"], name: "index_spaces_on_property"
    t.index ["spaceable_type", "spaceable_id"], name: "index_spaces_on_spaceable_type_and_spaceable_id"
    t.index ["user_id"], name: "index_spaces_on_user_id"
  end

  create_table "storages", id: :serial, force: :cascade do |t|
    t.integer "checkin_time", default: 0
    t.integer "category", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.integer "features", default: [], array: true
    t.integer "facilities", default: [], array: true
    t.integer "rules", default: [], array: true
    t.string "other_rules"
    t.integer "edit_status"
    t.index ["user_id"], name: "index_storages_on_user_id"
  end

  create_table "user_avatars", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "image"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_user_avatars_on_user_id"
  end

  create_table "user_favorite_space_relations", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "space_id"
    t.index ["space_id"], name: "index_user_favorite_space_relations_on_space_id"
    t.index ["user_id"], name: "index_user_favorite_space_relations_on_user_id"
  end

  create_table "user_notification_relations", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "notification_id"
    t.index ["notification_id"], name: "index_user_notification_relations_on_notification_id"
    t.index ["user_id"], name: "index_user_notification_relations_on_user_id"
  end

  create_table "user_payment_methods", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "type", default: 0
    t.string "identifier"
    t.date "expiry_date"
    t.string "token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_user_payment_methods_on_user_id"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "first_name"
    t.string "last_name"
    t.integer "gender"
    t.date "birthday"
    t.string "phone"
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.string "phone_confirmation_token"
    t.datetime "phone_confirmation_at"
    t.datetime "phone_confirmation_sent_at"
    t.string "unconfirmed_phone"
    t.string "gov_id"
    t.string "unconfirmed_gov_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "provider"
    t.string "uid"
    t.datetime "notifications_seen_at"
    t.text "biography"
    t.string "preferred_phone"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["phone_confirmation_token"], name: "index_users_on_phone_confirmation_token", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "verification_codes", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "type"
    t.string "code"
    t.datetime "expiry_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["expiry_at"], name: "index_verification_codes_on_expiry_at"
    t.index ["type", "code"], name: "index_verification_codes_on_type_and_code"
    t.index ["user_id"], name: "index_verification_codes_on_user_id"
  end

  create_table "versions", id: :serial, force: :cascade do |t|
    t.string "item_type", null: false
    t.integer "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.datetime "created_at"
    t.text "object_changes"
    t.string "request_id"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  add_foreign_key "admin_action_logs", "admins"
  add_foreign_key "bank_accounts", "users"
  add_foreign_key "booking_slots", "spaces"
  add_foreign_key "channels", "users", column: "guest_id"
  add_foreign_key "channels", "users", column: "host_id"
  add_foreign_key "contacts", "users"
  add_foreign_key "notifications", "admins"
  add_foreign_key "orders", "spaces"
  add_foreign_key "orders", "users", column: "guest_id"
  add_foreign_key "orders", "users", column: "host_id"
  add_foreign_key "payments", "orders"
  add_foreign_key "payments", "users"
  add_foreign_key "ratings", "orders"
  add_foreign_key "ratings", "users"
  add_foreign_key "service_fees", "orders"
  add_foreign_key "spaces", "users"
  add_foreign_key "user_avatars", "users"
  add_foreign_key "user_payment_methods", "users"
  add_foreign_key "verification_codes", "users"
end
