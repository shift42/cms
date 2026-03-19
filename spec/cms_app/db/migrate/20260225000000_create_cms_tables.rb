# frozen_string_literal: true

class CreateCmsTables < ActiveRecord::Migration[7.1]
  def change
    enable_extension "unaccent" unless extension_enabled?("unaccent")

    create_table :cms_sites do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.boolean :published, null: false, default: false
      t.string :default_locale, null: false, default: "en"
      t.timestamps
    end

    add_index :cms_sites, :slug, unique: true

    create_table :cms_pages do |t|
      t.references :site, null: false, foreign_key: { to_table: :cms_sites }
      t.bigint :parent_id
      t.string :slug, null: false
      t.integer :position, null: false, default: 0
      t.boolean :home, null: false, default: false
      t.string :template_key, null: false, default: "standard"
      t.string :status, null: false, default: "draft"
      t.boolean :show_in_header, null: false, default: true
      t.boolean :show_in_footer, null: false, default: false
      t.string :nav_group, null: false, default: "main"
      t.integer :nav_order, null: false, default: 0
      t.integer :footer_order, null: false, default: 0
      t.integer :depth, null: false, default: 0
      t.string :preview_token
      t.datetime :discarded_at
      t.timestamps
    end

    add_index :cms_pages, %i[site_id slug], unique: true
    add_index :cms_pages, %i[site_id status position]
    add_index :cms_pages, %i[site_id nav_group nav_order]
    add_index :cms_pages, :parent_id
    add_index :cms_pages, :preview_token, unique: true
    add_index :cms_pages, :discarded_at

    add_foreign_key :cms_pages, :cms_pages, column: :parent_id

    create_table :cms_page_translations do |t|
      t.references :page, null: false, foreign_key: { to_table: :cms_pages }
      t.string :locale, null: false
      t.string :title, null: false
      t.string :seo_title
      t.string :seo_description
      t.timestamps
    end

    add_index :cms_page_translations, %i[page_id locale], unique: true

    create_table :cms_images do |t|
      t.references :site, null: false, foreign_key: { to_table: :cms_sites }
      t.string :title, null: false
      t.timestamps
    end

    create_table :cms_image_translations do |t|
      t.references :image, null: false, foreign_key: { to_table: :cms_images }
      t.string :locale, null: false
      t.string :alt_text, null: false
      t.string :caption
      t.timestamps
    end

    add_index :cms_image_translations, %i[image_id locale], unique: true

    create_table :cms_sections do |t|
      t.references :site, null: false, foreign_key: { to_table: :cms_sites }
      t.string :kind, null: false, default: "rich_text"
      t.boolean :global, null: false, default: false
      t.boolean :enabled, null: false, default: true
      t.jsonb :settings, null: false, default: {}
      t.datetime :discarded_at
      t.timestamps
    end

    add_index :cms_sections, %i[site_id kind]
    add_index :cms_sections, %i[site_id global kind]
    add_index :cms_sections, :discarded_at

    create_table :cms_section_translations do |t|
      t.references :section, null: false, foreign_key: { to_table: :cms_sections }
      t.string :locale, null: false
      t.string :title, null: false
      t.string :subtitle
      t.timestamps
    end

    add_index :cms_section_translations, %i[section_id locale], unique: true

    create_table :cms_section_images do |t|
      t.references :section, null: false, foreign_key: { to_table: :cms_sections }
      t.references :image, null: false, foreign_key: { to_table: :cms_images }
      t.integer :position, null: false, default: 0
      t.timestamps
    end

    add_index :cms_section_images, %i[section_id position]
    add_index :cms_section_images, %i[section_id image_id], unique: true

    create_table :cms_documents do |t|
      t.references :site, null: false, foreign_key: { to_table: :cms_sites }
      t.string :title, null: false
      t.text :description
      t.timestamps
    end

    create_table :cms_page_sections do |t|
      t.references :page, null: false, foreign_key: { to_table: :cms_pages }
      t.references :section, null: false, foreign_key: { to_table: :cms_sections }
      t.integer :position, null: false, default: 0
      t.timestamps
    end

    add_index :cms_page_sections, %i[page_id position]
    add_index :cms_page_sections, %i[page_id section_id], unique: true

    create_table :cms_form_fields do |t|
      t.references :page, null: false, foreign_key: { to_table: :cms_pages }
      t.string :kind, null: false, default: "text"
      t.string :label, null: false
      t.string :field_name, null: false
      t.string :placeholder
      t.string :hint
      t.boolean :required, null: false, default: false
      t.jsonb :options, null: false, default: []
      t.integer :position, null: false, default: 0
      t.timestamps
    end

    add_index :cms_form_fields, %i[page_id position]
    add_index :cms_form_fields, %i[page_id field_name], unique: true

    create_table :cms_form_submissions do |t|
      t.references :page, null: false, foreign_key: { to_table: :cms_pages }
      t.jsonb :data, null: false, default: {}
      t.string :ip_address
      t.datetime :created_at, null: false, default: -> { "CURRENT_TIMESTAMP" }
    end

    add_index :cms_form_submissions, :created_at

    create_table :cms_api_keys do |t|
      t.references :site, null: false, foreign_key: { to_table: :cms_sites }
      t.string :name, null: false
      t.string :token, null: false
      t.boolean :active, null: false, default: true
      t.datetime :last_used_at
      t.timestamps
    end

    add_index :cms_api_keys, :token, unique: true

    create_table :cms_webhooks do |t|
      t.references :site, null: false, foreign_key: { to_table: :cms_sites }
      t.string :url, null: false
      t.jsonb :events, null: false, default: []
      t.string :secret
      t.boolean :active, null: false, default: true
      t.timestamps
    end

    create_table :cms_webhook_deliveries do |t|
      t.references :webhook, null: false, foreign_key: { to_table: :cms_webhooks }
      t.string :event, null: false
      t.integer :response_code
      t.text :response_body
      t.boolean :success, null: false, default: false
      t.string :error_message
      t.datetime :delivered_at, null: false, default: -> { "CURRENT_TIMESTAMP" }
    end

    add_index :cms_webhook_deliveries, %i[webhook_id delivered_at]

    return if table_exists?(:action_text_rich_texts)

    create_table :action_text_rich_texts do |t|
      t.string :name, null: false
      t.text :body
      t.references :record, null: false, polymorphic: true, index: false
      t.timestamps
    end

    add_index :action_text_rich_texts,
              %i[record_type record_id name],
              unique: true,
              name: "index_action_text_rich_texts_uniqueness"
  end
end
