# frozen_string_literal: true

module Cms
  class Page < ApplicationRecord
    include ::Discard::Model

    self.table_name = "cms_pages"

    MAX_DEPTH = 10

    module TemplateRegistry
      class << self
        def register(key)
          normalized = key.to_s.parameterize.underscore
          return if normalized.blank?

          registered[normalized] = true
        end

        def registered_keys
          registered.keys
        end

        private

        def registered
          @registered ||= begin
            defaults = %w[standard landing form custom]
            defaults.index_with { true }
          end
        end
      end
    end

    has_one_attached :hero_image
    has_many_attached :media_files

    belongs_to :site,
               class_name: "Cms::Site",
               inverse_of: :pages

    belongs_to :parent,
               class_name: "Cms::Page",
               optional: true,
               inverse_of: :subpages

    has_many :subpages,
             class_name: "Cms::Page",
             foreign_key: :parent_id,
             dependent: :nullify,
             inverse_of: :parent

    has_many :page_translations,
             class_name: "Cms::PageTranslation",
             foreign_key: :page_id,
             inverse_of: :page,
             dependent: :destroy

    accepts_nested_attributes_for :page_translations

    has_one :localised, -> { where(locale: I18n.locale.to_s) },
            class_name: "Cms::PageTranslation",
            foreign_key: :page_id,
            inverse_of: :page

    delegate :title, :seo_title, :seo_description,
             to: :localised, allow_nil: true

    has_many :page_sections,
             class_name: "Cms::PageSection",
             foreign_key: :page_id,
             inverse_of: :page,
             dependent: :destroy

    has_many :sections,
             through: :page_sections,
             source: :section

    has_many :form_fields,
             class_name: "Cms::FormField",
             foreign_key: :page_id,
             inverse_of: :page,
             dependent: :destroy

    has_many :form_submissions,
             class_name: "Cms::FormSubmission",
             foreign_key: :page_id,
             inverse_of: :page,
             dependent: :destroy

    enum :status,
         {
           draft: "draft",
           published: "published",
           archived: "archived"
         },
         prefix: true

    validates :slug, presence: true
    validates :slug, uniqueness: { scope: :site_id }
    validates :template_key, presence: true, inclusion: { in: ->(_) { template_keys } }
    validates :depth, numericality: { less_than_or_equal_to: MAX_DEPTH }
    validate :published_pages_require_sections

    before_create :generate_preview_token
    before_validation :set_slug
    before_validation :normalize_home_slug
    before_validation :set_defaults
    before_validation :compute_depth
    before_save :ensure_single_home_page, if: -> { home? && will_save_change_to_home? }
    after_commit :fire_webhooks_on_status_change, on: %i[create update]
    after_save :update_descendant_depths, if: :saved_change_to_parent_id?

    scope :ordered, -> { order(:position, :id) }
    scope :root, -> { where(parent_id: nil) }
    scope :published, -> { where(status: "published") }
    scope :header_nav, -> { where(show_in_header: true).where.not(nav_group: "none").order(:nav_order, :position, :id) }
    scope :footer_nav, lambda {
      where(show_in_footer: true).where.not(nav_group: "none").order(:footer_order, :position, :id)
    }
    scope :search, lambda { |q|
      joins(:page_translations)
        .where(
          "lower(unaccent(cms_page_translations.title)) ilike lower(unaccent(?)) OR " \
          "lower(unaccent(cms_pages.slug)) ilike lower(unaccent(?))",
          "%#{q}%", "%#{q}%"
        ).distinct
    }
    scope :search_ordered, ->(q) { search(q).ordered }

    def self.template_keys
      TemplateRegistry.registered_keys
    end

    def display_title
      title.presence || slug.to_s.humanize
    end

    def display_meta_title
      seo_title.presence || display_title
    end

    def ancestors
      parent ? parent.ancestors + [parent] : []
    end

    def descendants
      subpages.flat_map { |p| [p] + p.descendants }
    end

    def ordered_page_sections
      page_sections.ordered.includes(:section)
    end

    def public_path_segments
      return [] if home?

      (ancestors + [self]).reject(&:home?).map(&:slug)
    end

    def public_path
      public_path_segments.join("/")
    end

    private

    def compute_depth
      self.depth = parent ? (parent.depth + 1) : 0
    end

    def update_descendant_depths(parent_depth = depth)
      subpages.find_each do |child|
        child.update_column(:depth, parent_depth + 1)
        child.update_descendant_depths(parent_depth + 1)
      end
    end

    def fire_webhooks_on_status_change
      return unless saved_change_to_status?

      event = case status
              when "published" then "page.published"
              when "archived"  then "page.unpublished"
              end
      return if event.blank?

      site.webhooks.active.each do |webhook|
        Cms::DeliverWebhookJob.perform_later(webhook.id, event, { "page_id" => id, "slug" => slug })
      end
    rescue StandardError
      # Webhook delivery failures must never break page saves
    end

    def set_slug
      default_locale = site.default_locale.presence || I18n.default_locale.to_s
      translation_title = page_translations.find { |t| t.locale == default_locale }&.title if page_translations.loaded?

      self.slug = slug.to_s.parameterize if slug.present?
      self.slug = translation_title.to_s.parameterize if slug.blank? && translation_title.present?
    end

    def normalize_home_slug
      self.slug = "home" if home?
    end

    def set_defaults
      self.template_key = "standard" if template_key.blank?
      self.nav_group = "main" if nav_group.blank?
    end

    def generate_preview_token
      self.preview_token ||= SecureRandom.urlsafe_base64(32)
    end

    def ensure_single_home_page
      site.pages.where.not(id: id).where(home: true).find_each do |page|
        page.update!(home: false)
      end
    end

    def published_pages_require_sections
      return unless status_published?
      return if page_sections.loaded? ? page_sections.reject(&:marked_for_destruction?).any? : page_sections.exists?

      errors.add(:base, I18n.t("cms.errors.page.sections_required"))
    end
  end
end
