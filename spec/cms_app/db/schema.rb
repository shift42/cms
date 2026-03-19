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

ActiveRecord::Schema[8.1].define(version: 2026_02_25_000001) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "unaccent"

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "cms_api_keys", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "last_used_at"
    t.string "name", null: false
    t.bigint "site_id", null: false
    t.string "token", null: false
    t.datetime "updated_at", null: false
    t.index ["site_id"], name: "index_cms_api_keys_on_site_id"
    t.index ["token"], name: "index_cms_api_keys_on_token", unique: true
  end

  create_table "cms_documents", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.bigint "site_id", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["site_id"], name: "index_cms_documents_on_site_id"
  end

  create_table "cms_form_fields", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "field_name", null: false
    t.string "hint"
    t.string "kind", default: "text", null: false
    t.string "label", null: false
    t.jsonb "options", default: [], null: false
    t.bigint "page_id", null: false
    t.string "placeholder"
    t.integer "position", default: 0, null: false
    t.boolean "required", default: false, null: false
    t.datetime "updated_at", null: false
    t.index ["page_id", "field_name"], name: "index_cms_form_fields_on_page_id_and_field_name", unique: true
    t.index ["page_id", "position"], name: "index_cms_form_fields_on_page_id_and_position"
    t.index ["page_id"], name: "index_cms_form_fields_on_page_id"
  end

  create_table "cms_form_submissions", force: :cascade do |t|
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.jsonb "data", default: {}, null: false
    t.string "ip_address"
    t.bigint "page_id", null: false
    t.index ["created_at"], name: "index_cms_form_submissions_on_created_at"
    t.index ["page_id"], name: "index_cms_form_submissions_on_page_id"
  end

  create_table "cms_image_translations", force: :cascade do |t|
    t.string "alt_text", null: false
    t.string "caption"
    t.datetime "created_at", null: false
    t.bigint "image_id", null: false
    t.string "locale", null: false
    t.datetime "updated_at", null: false
    t.index ["image_id", "locale"], name: "index_cms_image_translations_on_image_id_and_locale", unique: true
    t.index ["image_id"], name: "index_cms_image_translations_on_image_id"
  end

  create_table "cms_images", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "site_id", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["site_id"], name: "index_cms_images_on_site_id"
  end

  create_table "cms_page_sections", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "page_id", null: false
    t.integer "position", default: 0, null: false
    t.bigint "section_id", null: false
    t.datetime "updated_at", null: false
    t.index ["page_id", "position"], name: "index_cms_page_sections_on_page_id_and_position"
    t.index ["page_id", "section_id"], name: "index_cms_page_sections_on_page_id_and_section_id", unique: true
    t.index ["page_id"], name: "index_cms_page_sections_on_page_id"
    t.index ["section_id"], name: "index_cms_page_sections_on_section_id"
  end

  create_table "cms_page_translations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "locale", null: false
    t.bigint "page_id", null: false
    t.string "seo_description"
    t.string "seo_title"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["page_id", "locale"], name: "index_cms_page_translations_on_page_id_and_locale", unique: true
    t.index ["page_id"], name: "index_cms_page_translations_on_page_id"
  end

  create_table "cms_pages", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "depth", default: 0, null: false
    t.datetime "discarded_at"
    t.integer "footer_order", default: 0, null: false
    t.boolean "home", default: false, null: false
    t.string "nav_group", default: "main", null: false
    t.integer "nav_order", default: 0, null: false
    t.bigint "parent_id"
    t.integer "position", default: 0, null: false
    t.string "preview_token"
    t.boolean "show_in_footer", default: false, null: false
    t.boolean "show_in_header", default: true, null: false
    t.bigint "site_id", null: false
    t.string "slug", null: false
    t.string "status", default: "draft", null: false
    t.string "template_key", default: "standard", null: false
    t.datetime "updated_at", null: false
    t.index ["discarded_at"], name: "index_cms_pages_on_discarded_at"
    t.index ["parent_id"], name: "index_cms_pages_on_parent_id"
    t.index ["preview_token"], name: "index_cms_pages_on_preview_token", unique: true
    t.index ["site_id", "nav_group", "nav_order"], name: "index_cms_pages_on_site_id_and_nav_group_and_nav_order"
    t.index ["site_id", "slug"], name: "index_cms_pages_on_site_id_and_slug", unique: true
    t.index ["site_id", "status", "position"], name: "index_cms_pages_on_site_id_and_status_and_position"
    t.index ["site_id"], name: "index_cms_pages_on_site_id"
  end

  create_table "cms_sections", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "discarded_at"
    t.boolean "enabled", default: true, null: false
    t.boolean "global", default: false, null: false
    t.string "kind", default: "rich_text", null: false
    t.jsonb "settings", default: {}, null: false
    t.bigint "site_id", null: false
    t.datetime "updated_at", null: false
    t.index ["discarded_at"], name: "index_cms_sections_on_discarded_at"
    t.index ["site_id", "global", "kind"], name: "index_cms_sections_on_site_id_and_global_and_kind"
    t.index ["site_id", "kind"], name: "index_cms_sections_on_site_id_and_kind"
    t.index ["site_id"], name: "index_cms_sections_on_site_id"
  end

  create_table "cms_section_translations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "locale", null: false
    t.bigint "section_id", null: false
    t.string "subtitle"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["section_id", "locale"], name: "index_cms_section_translations_on_section_id_and_locale", unique: true
    t.index ["section_id"], name: "index_cms_section_translations_on_section_id"
  end

  create_table "cms_section_images", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "image_id", null: false
    t.integer "position", default: 0, null: false
    t.bigint "section_id", null: false
    t.datetime "updated_at", null: false
    t.index ["section_id", "image_id"], name: "index_cms_section_images_on_section_id_and_image_id", unique: true
    t.index ["section_id", "position"], name: "index_cms_section_images_on_section_id_and_position"
    t.index ["image_id"], name: "index_cms_section_images_on_image_id"
    t.index ["section_id"], name: "index_cms_section_images_on_section_id"
  end

  create_table "cms_sites", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "default_locale", default: "en", null: false
    t.string "name", null: false
    t.boolean "published", default: false, null: false
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_cms_sites_on_slug", unique: true
  end

  create_table "cms_webhook_deliveries", force: :cascade do |t|
    t.datetime "delivered_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.string "error_message"
    t.string "event", null: false
    t.text "response_body"
    t.integer "response_code"
    t.boolean "success", default: false, null: false
    t.bigint "webhook_id", null: false
    t.index ["webhook_id", "delivered_at"], name: "index_cms_webhook_deliveries_on_webhook_id_and_delivered_at"
    t.index ["webhook_id"], name: "index_cms_webhook_deliveries_on_webhook_id"
  end

  create_table "cms_webhooks", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.jsonb "events", default: [], null: false
    t.string "secret"
    t.bigint "site_id", null: false
    t.datetime "updated_at", null: false
    t.string "url", null: false
    t.index ["site_id"], name: "index_cms_webhooks_on_site_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "cms_api_keys", "cms_sites", column: "site_id"
  add_foreign_key "cms_documents", "cms_sites", column: "site_id"
  add_foreign_key "cms_form_fields", "cms_pages", column: "page_id"
  add_foreign_key "cms_form_submissions", "cms_pages", column: "page_id"
  add_foreign_key "cms_image_translations", "cms_images", column: "image_id"
  add_foreign_key "cms_images", "cms_sites", column: "site_id"
  add_foreign_key "cms_page_sections", "cms_pages", column: "page_id"
  add_foreign_key "cms_page_sections", "cms_sections", column: "section_id"
  add_foreign_key "cms_page_translations", "cms_pages", column: "page_id"
  add_foreign_key "cms_pages", "cms_pages", column: "parent_id"
  add_foreign_key "cms_pages", "cms_sites", column: "site_id"
  add_foreign_key "cms_section_images", "cms_images", column: "image_id"
  add_foreign_key "cms_section_images", "cms_sections", column: "section_id"
  add_foreign_key "cms_section_translations", "cms_sections", column: "section_id"
  add_foreign_key "cms_sections", "cms_sites", column: "site_id"
  add_foreign_key "cms_webhook_deliveries", "cms_webhooks", column: "webhook_id"
  add_foreign_key "cms_webhooks", "cms_sites", column: "site_id"
end
