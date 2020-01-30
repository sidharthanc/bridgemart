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

ActiveRecord::Schema.define(version: 2020_01_07_071135) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "active_admin_comments", force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_type"
    t.bigint "resource_id"
    t.string "author_type"
    t.bigint "author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_id", "author_type"], name: "index_active_admin_comments_on_author_id_and_author_type"
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_id", "resource_type"], name: "index_active_admin_comments_on_resource_id_and_resource_type"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id"
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "addresses", force: :cascade do |t|
    t.string "addressable_type"
    t.bigint "addressable_id"
    t.string "street1"
    t.string "street2"
    t.string "city"
    t.string "state"
    t.string "zip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["addressable_id", "addressable_type"], name: "index_addresses_on_addressable_id_and_addressable_type"
    t.index ["addressable_type", "addressable_id"], name: "index_addresses_on_addressable_type_and_addressable_id"
  end

  create_table "audits", force: :cascade do |t|
    t.integer "auditable_id"
    t.string "auditable_type"
    t.integer "associated_id"
    t.string "associated_type"
    t.integer "user_id"
    t.string "user_type"
    t.string "username"
    t.string "action"
    t.jsonb "audited_changes"
    t.integer "version", default: 0
    t.string "comment"
    t.string "remote_address"
    t.string "request_uuid"
    t.datetime "created_at"
    t.index ["associated_id", "associated_type"], name: "index_audits_on_associated_id_and_associated_type"
    t.index ["associated_type", "associated_id"], name: "associated_index"
    t.index ["auditable_id", "auditable_type"], name: "index_audits_on_auditable_id_and_auditable_type"
    t.index ["auditable_type", "auditable_id"], name: "auditable_index"
    t.index ["created_at"], name: "index_audits_on_created_at"
    t.index ["request_uuid"], name: "index_audits_on_request_uuid"
    t.index ["user_id", "user_type"], name: "user_index"
  end

  create_table "billing_contacts", force: :cascade do |t|
    t.bigint "plan_id"
    t.string "email"
    t.string "first_name"
    t.string "last_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "billable_type"
    t.bigint "billable_id"
    t.datetime "discarded_at"
    t.index ["billable_id", "billable_type"], name: "index_billing_contacts_on_billable_id_and_billable_type"
    t.index ["billable_type", "billable_id"], name: "index_billing_contacts_on_billable_type_and_billable_id"
    t.index ["discarded_at"], name: "index_billing_contacts_on_discarded_at"
    t.index ["plan_id"], name: "index_billing_contacts_on_plan_id"
  end

  create_table "codes", force: :cascade do |t|
    t.bigint "member_id"
    t.integer "balance_cents", default: 0
    t.integer "limit_cents"
    t.string "status"
    t.string "external_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deactivated_at"
    t.string "authentication_token"
    t.bigint "plan_product_category_id"
    t.string "barcode_url"
    t.string "card_image_url"
    t.boolean "delivered", default: false, null: false
    t.bigint "legacy_identifier"
    t.jsonb "fields", default: {}
    t.datetime "discarded_at"
    t.datetime "deleted_at"
    t.integer "unloaded_amount_cents", default: 0
    t.datetime "deactivated_email_sent_at"
    t.datetime "locked_at"
    t.datetime "registered_at"
    t.string "virtual_card_provider"
    t.uuid "uuid", default: -> { "gen_random_uuid()" }
    t.date "starts_on"
    t.date "expires_on"
    t.string "encrypted_pin"
    t.string "encrypted_pin_iv"
    t.string "encrypted_card_number"
    t.string "encrypted_card_number_iv"
    t.string "pan"
    t.index ["deleted_at"], name: "index_codes_on_deleted_at"
    t.index ["discarded_at"], name: "index_codes_on_discarded_at", where: "(deleted_at IS NULL)"
    t.index ["encrypted_card_number"], name: "index_codes_on_encrypted_card_number", unique: true
    t.index ["legacy_identifier"], name: "index_codes_on_legacy_identifier", unique: true
    t.index ["member_id"], name: "index_codes_on_member_id", where: "(deleted_at IS NULL)"
    t.index ["plan_product_category_id"], name: "index_codes_on_plan_product_category_id", where: "(deleted_at IS NULL)"
  end

  create_table "commercial_agreements", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "organization_id"
  end

  create_table "credit_purchases", force: :cascade do |t|
    t.datetime "paid_at"
    t.datetime "voided_at"
    t.string "po_number"
    t.string "error_message"
    t.boolean "processing", default: false
    t.integer "amount_cents", default: 0, null: false
    t.string "amount_currency", default: "USD", null: false
    t.bigint "organization_id"
    t.bigint "payment_method_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_credit_purchases_on_deleted_at"
    t.index ["organization_id"], name: "index_credit_purchases_on_organization_id", where: "(deleted_at IS NULL)"
    t.index ["payment_method_id"], name: "index_credit_purchases_on_payment_method_id", where: "(deleted_at IS NULL)"
  end

  create_table "credits", force: :cascade do |t|
    t.string "source_type"
    t.bigint "source_id"
    t.integer "amount_cents", default: 0, null: false
    t.string "amount_currency", default: "USD", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "organization_id"
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_credits_on_deleted_at"
    t.index ["organization_id"], name: "index_credits_on_organization_id", where: "(deleted_at IS NULL)"
    t.index ["source_id", "source_type"], name: "index_credits_on_source_id_and_source_type", where: "(deleted_at IS NULL)"
    t.index ["source_type", "source_id"], name: "index_credits_on_source_type_and_source_id", where: "(deleted_at IS NULL)"
  end

  create_table "divisions", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "discarded_at"
    t.index ["discarded_at"], name: "index_divisions_on_discarded_at"
  end

  create_table "fees", force: :cascade do |t|
    t.string "description"
    t.integer "rate_cents", default: 0, null: false
    t.string "rate_currency", default: "USD", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "import_errors", force: :cascade do |t|
    t.string "full_filepath"
    t.string "error_message"
    t.bigint "csv_row_number"
    t.jsonb "csv_record"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "line_items", force: :cascade do |t|
    t.bigint "order_id", null: false
    t.string "source_type"
    t.bigint "source_id"
    t.string "description"
    t.integer "charge_type", default: 0
    t.integer "amount_cents", default: 0, null: false
    t.string "amount_currency", default: "USD", null: false
    t.integer "quantity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_line_items_on_deleted_at"
    t.index ["order_id"], name: "index_line_items_on_order_id", where: "(deleted_at IS NULL)"
    t.index ["source_id", "source_type"], name: "index_line_items_on_source_id_and_source_type", where: "(deleted_at IS NULL)"
    t.index ["source_type", "source_id"], name: "index_line_items_on_source_type_and_source_id", where: "(deleted_at IS NULL)"
  end

  create_table "member_imports", force: :cascade do |t|
    t.json "problems"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "order_id"
    t.boolean "acknowledged", default: false, null: false
    t.index ["acknowledged"], name: "index_member_imports_on_acknowledged", where: "((acknowledged IS FALSE) AND (problems IS NOT NULL))"
    t.index ["order_id"], name: "index_member_imports_on_order_id"
  end

  create_table "members", force: :cascade do |t|
    t.string "first_name"
    t.string "middle_name"
    t.string "last_name"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "phone"
    t.datetime "deactivated_at"
    t.string "authentication_token"
    t.bigint "order_id"
    t.string "external_member_id"
    t.datetime "deleted_at"
    t.uuid "uuid", default: -> { "gen_random_uuid()" }
    t.index ["deleted_at"], name: "index_members_on_deleted_at"
    t.index ["order_id"], name: "index_members_on_order_id", where: "(deleted_at IS NULL)"
  end

  create_table "notifications", force: :cascade do |t|
    t.string "sent_to", null: false
    t.string "notice_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "fields"
    t.string "template_id"
    t.index ["sent_to"], name: "index_notifications_on_sent_to"
  end

  create_table "nyan_cash_cards", force: :cascade do |t|
    t.string "card_number"
    t.string "pin"
    t.datetime "locked_at"
    t.datetime "expires_at"
    t.datetime "closed_at"
    t.integer "initial_balance"
    t.integer "current_balance"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "orders", force: :cascade do |t|
    t.bigint "plan_id"
    t.datetime "paid_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "starts_on"
    t.date "ends_on"
    t.string "po_number"
    t.bigint "payment_method_id"
    t.datetime "started_at"
    t.string "error_message"
    t.integer "amount_cents", default: 0, null: false
    t.string "amount_currency", default: "USD", null: false
    t.boolean "paid", default: false
    t.string "legacy_identifier"
    t.datetime "discarded_at"
    t.integer "applied_credit_cents", default: 0, null: false
    t.string "applied_credit_currency", default: "USD", null: false
    t.datetime "deleted_at"
    t.datetime "processed_at"
    t.string "transaction_number"
    t.boolean "is_cancelled", default: false
    t.datetime "generated_at"
    t.integer "members_count", default: 0
    t.integer "total_cached_cents"
    t.text "notes"
    t.integer "total_fees_cached_cents"
    t.integer "total_charges_cached_cents"
    t.uuid "uuid", default: -> { "gen_random_uuid()" }
    t.datetime "invoice_sent_at"
    t.index ["deleted_at"], name: "index_orders_on_deleted_at"
    t.index ["discarded_at"], name: "index_orders_on_discarded_at", where: "(deleted_at IS NULL)"
    t.index ["id", "starts_on", "ends_on"], name: "index_orders_on_id_and_starts_on_and_ends_on"
    t.index ["legacy_identifier"], name: "index_orders_on_legacy_identifier", unique: true
    t.index ["payment_method_id"], name: "index_orders_on_payment_method_id", where: "(deleted_at IS NULL)"
    t.index ["plan_id"], name: "index_orders_on_plan_id", where: "(deleted_at IS NULL)"
  end

  create_table "orders_special_offers", id: false, force: :cascade do |t|
    t.bigint "order_id", null: false
    t.bigint "special_offer_id", null: false
    t.index ["order_id", "special_offer_id"], name: "index_orders_special_offers_on_order_id_and_special_offer_id"
    t.index ["order_id"], name: "index_orders_special_offers_on_order_id"
    t.index ["special_offer_id"], name: "index_orders_special_offers_on_special_offer_id"
  end

  create_table "organization_users", force: :cascade do |t|
    t.bigint "organization_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_organization_users_on_deleted_at"
    t.index ["organization_id"], name: "index_organization_users_on_organization_id", where: "(deleted_at IS NULL)"
    t.index ["user_id"], name: "index_organization_users_on_user_id", where: "(deleted_at IS NULL)"
  end

  create_table "organizations", force: :cascade do |t|
    t.string "name"
    t.string "industry"
    t.string "number_of_employees"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "number_of_employees_with_safety_rx_eyewear"
    t.integer "primary_user_id"
    t.text "purchase_instructions"
    t.string "legacy_identifier"
    t.datetime "discarded_at"
    t.datetime "deleted_at"
    t.integer "members_count", default: 0
    t.integer "credit_total_cached_cents"
    t.integer "usage_total_cached_cents"
    t.string "account_status_cached"
    t.uuid "uuid", default: -> { "gen_random_uuid()" }
    t.string "authentication_token"
    t.index ["created_at"], name: "index_organizations_on_created_at", where: "(deleted_at IS NULL)"
    t.index ["deleted_at"], name: "index_organizations_on_deleted_at"
    t.index ["discarded_at"], name: "index_organizations_on_discarded_at", where: "(deleted_at IS NULL)"
    t.index ["legacy_identifier"], name: "index_organizations_on_legacy_identifier", unique: true
    t.index ["primary_user_id"], name: "index_organizations_on_primary_user_id", where: "(deleted_at IS NULL)"
  end

  create_table "payment_methods", force: :cascade do |t|
    t.bigint "organization_id"
    t.string "customer_vault_id"
    t.string "billing_id"
    t.string "ach_account_name"
    t.string "ach_account_token"
    t.string "ach_account_type"
    t.string "credit_card_token"
    t.string "credit_card_expiration_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "location_id"
    t.datetime "deleted_at"
    t.index ["customer_vault_id"], name: "index_payment_methods_on_customer_vault_id", where: "(deleted_at IS NULL)"
    t.index ["deleted_at"], name: "index_payment_methods_on_deleted_at"
    t.index ["location_id"], name: "index_payment_methods_on_location_id", where: "(deleted_at IS NULL)"
    t.index ["organization_id"], name: "index_payment_methods_on_organization_id", where: "(deleted_at IS NULL)"
  end

  create_table "permission_group_ownerships", force: :cascade do |t|
    t.bigint "permission_group_id"
    t.bigint "owner_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["owner_id"], name: "index_permission_group_ownerships_on_owner_id"
    t.index ["owner_id"], name: "index_pgo_on_permission_group_id_and_user_id"
    t.index ["permission_group_id"], name: "index_permission_group_ownerships_on_permission_group_id"
  end

  create_table "permission_groups", force: :cascade do |t|
    t.string "name", default: "", null: false
    t.boolean "admin", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "default_for", default: 0
  end

  create_table "permission_groups_users", id: false, force: :cascade do |t|
    t.bigint "permission_group_id", null: false
    t.bigint "user_id", null: false
    t.index ["permission_group_id", "user_id"], name: "index_pgu_on_permission_group_id_and_user_id"
    t.index ["permission_group_id"], name: "index_permission_groups_users_on_permission_group_id"
    t.index ["user_id"], name: "index_permission_groups_users_on_user_id"
  end

  create_table "permissions", force: :cascade do |t|
    t.bigint "permission_group_id", null: false
    t.string "target", null: false
    t.boolean "update_permitted", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "create_permitted", default: false, null: false
    t.index ["create_permitted", "target"], name: "index_permissions_on_create_permitted_and_target"
    t.index ["permission_group_id"], name: "index_permissions_on_permission_group_id"
    t.index ["update_permitted", "target"], name: "index_permissions_on_update_permitted_and_target"
  end

  create_table "plan_product_categories", force: :cascade do |t|
    t.bigint "plan_id", null: false
    t.bigint "product_category_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "budget_cents", default: 0, null: false
    t.string "budget_currency", default: "USD", null: false
    t.string "usage_type", default: "multi_use"
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_plan_product_categories_on_deleted_at"
    t.index ["plan_id"], name: "index_plan_product_categories_on_plan_id"
    t.index ["product_category_id"], name: "index_plan_product_categories_on_product_category_id"
  end

  create_table "plans", force: :cascade do |t|
    t.bigint "organization_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "customer_vault_id"
    t.datetime "deleted_at"
    t.integer "members_count", default: 0
    t.index ["deleted_at"], name: "index_plans_on_deleted_at"
    t.index ["organization_id"], name: "index_plans_on_organization_id", where: "(deleted_at IS NULL)"
  end

  create_table "price_points", force: :cascade do |t|
    t.bigint "product_category_id", null: false
    t.integer "limit"
    t.string "verbiage"
    t.string "note"
    t.integer "limit_type"
    t.string "tooltip"
    t.string "upgrade_verbiage"
    t.string "item_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_category_id"], name: "index_price_points_on_product_category_id"
  end

  create_table "product_categories", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "description"
    t.string "background_color", default: "lightgreen"
    t.string "tooltip_description"
    t.bigint "division_id"
    t.text "product_description"
    t.integer "fee_type", default: 0
    t.float "percentage_fee"
    t.integer "flat_fee_cents", default: 0, null: false
    t.string "flat_fee_currency", default: "USD", null: false
    t.boolean "single_use_only", default: false
    t.boolean "redemption_instructions_editable", default: false
    t.string "product_bin"
    t.string "card_type"
    t.integer "hidden", default: 0
    t.text "default_redemption_instructions"
    t.datetime "deleted_at"
    t.boolean "use_organization_branding", default: false
    t.index ["deleted_at"], name: "index_product_categories_on_deleted_at"
    t.index ["division_id"], name: "index_product_categories_on_division_id", where: "(deleted_at IS NULL)"
  end

  create_table "redemption_instructions", force: :cascade do |t|
    t.text "description"
    t.string "title"
    t.boolean "active", default: false
    t.bigint "organization_id"
    t.bigint "product_category_id"
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_redemption_instructions_on_deleted_at"
    t.index ["organization_id"], name: "index_redemption_instructions_on_organization_id", where: "(deleted_at IS NULL)"
    t.index ["product_category_id"], name: "index_redemption_instructions_on_product_category_id", where: "(deleted_at IS NULL)"
  end

  create_table "service_activities", force: :cascade do |t|
    t.string "service"
    t.string "action"
    t.string "message"
    t.datetime "successful_at"
    t.datetime "failure_at"
    t.jsonb "exception", default: {}
    t.jsonb "metadata", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "settings", force: :cascade do |t|
    t.string "key", null: false
    t.string "value", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "signatures", force: :cascade do |t|
    t.bigint "organization_id"
    t.bigint "commercial_agreement_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["commercial_agreement_id"], name: "index_signatures_on_commercial_agreement_id", where: "(deleted_at IS NULL)"
    t.index ["deleted_at"], name: "index_signatures_on_deleted_at"
    t.index ["organization_id"], name: "index_signatures_on_organization_id", where: "(deleted_at IS NULL)"
  end

  create_table "special_offers", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.bigint "product_category_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "usage_instructions"
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_special_offers_on_deleted_at"
    t.index ["product_category_id"], name: "index_special_offers_on_product_category_id", where: "(deleted_at IS NULL)"
  end

  create_table "usage_imports", force: :cascade do |t|
    t.json "problems"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "usages", force: :cascade do |t|
    t.bigint "code_id"
    t.integer "amount_cents"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "activity"
    t.string "reason"
    t.string "result"
    t.string "notes"
    t.datetime "used_at"
    t.string "external_id"
    t.string "amount_currency", default: "USD", null: false
    t.string "visit_number"
    t.string "store_city"
    t.string "store_state"
    t.integer "total_usage_cents", default: 0, null: false
    t.string "total_usage_currency", default: "USD", null: false
    t.integer "total_per_visit_cents", default: 0, null: false
    t.string "total_per_visit_currency", default: "USD", null: false
    t.integer "retail_price_cents", default: 0, null: false
    t.string "retail_price_currency", default: "USD", null: false
    t.string "store_number"
    t.string "department_category"
    t.string "upc_number"
    t.string "upc_description"
    t.string "company_type"
    t.bigint "transaction_detail_identifier"
    t.datetime "deleted_at"
    t.index ["code_id"], name: "index_usages_on_code_id", where: "(deleted_at IS NULL)"
    t.index ["deleted_at"], name: "index_usages_on_deleted_at"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "authentication_token"
    t.datetime "token_expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "role"
    t.string "phone_number"
    t.string "broker_organization_name"
    t.string "title"
    t.datetime "discarded_at"
    t.datetime "deleted_at"
    t.boolean "use_enhanced_dashboard", default: false
    t.index ["authentication_token"], name: "index_users_on_authentication_token", unique: true
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["deleted_at"], name: "index_users_on_deleted_at"
    t.index ["discarded_at"], name: "index_users_on_discarded_at", where: "(deleted_at IS NULL)"
    t.index ["email", "deleted_at"], name: "index_users_on_email_and_deleted_at", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "codes", "members"
  add_foreign_key "codes", "plan_product_categories", on_delete: :cascade
  add_foreign_key "credits", "organizations"
  add_foreign_key "line_items", "orders"
  add_foreign_key "member_imports", "orders"
  add_foreign_key "members", "orders"
  add_foreign_key "orders", "plans"
  add_foreign_key "organization_users", "organizations"
  add_foreign_key "organization_users", "users"
  add_foreign_key "organizations", "users", column: "primary_user_id"
  add_foreign_key "plan_product_categories", "plans"
  add_foreign_key "plan_product_categories", "product_categories"
  add_foreign_key "plans", "organizations"
  add_foreign_key "price_points", "product_categories"
  add_foreign_key "special_offers", "product_categories"
  add_foreign_key "usages", "codes"

  create_view "order_statistics", sql_definition: <<-SQL
      SELECT orders.id,
      orders.id AS order_id,
      orders.starts_on,
      orders.ends_on,
      COALESCE(sum(codes.limit_cents), (0)::bigint) AS order_total_limit,
      COALESCE(sum(codes.balance_cents), (0)::bigint) AS order_total_balance,
      COALESCE(count(members.id), (0)::bigint) AS order_total_members,
      COALESCE(count(codes.id), (0)::bigint) AS order_total_codes
     FROM ((((orders
       JOIN plans ON (((orders.plan_id = plans.id) AND (plans.deleted_at IS NULL))))
       JOIN plan_product_categories ON ((plans.id = plan_product_categories.plan_id)))
       JOIN codes ON (((plan_product_categories.id = codes.plan_product_category_id) AND (codes.deleted_at IS NULL))))
       JOIN members ON (((codes.member_id = members.id) AND (members.deleted_at IS NULL))))
    GROUP BY orders.id, orders.starts_on, orders.ends_on;
  SQL
  create_view "organization_statistics", sql_definition: <<-SQL
      SELECT organizations.id,
      count(orders.id) AS total_orders,
      sum(member_counts.member_count) AS total_members,
      sum(order_statistics.order_total_limit) AS total_load,
      sum(order_statistics.order_total_balance) AS total_balance,
      sum(order_statistics.order_total_codes) AS total_codes,
      organizations.id AS organization_id
     FROM ((((organizations
       JOIN plans ON ((organizations.id = plans.organization_id)))
       JOIN orders ON ((plans.id = orders.plan_id)))
       LEFT JOIN order_statistics ON ((orders.id = order_statistics.order_id)))
       LEFT JOIN ( SELECT members.order_id,
              count(members.id) AS member_count
             FROM members
            GROUP BY members.order_id) member_counts ON ((orders.id = member_counts.order_id)))
    GROUP BY organizations.id;
  SQL
end
