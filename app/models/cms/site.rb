# frozen_string_literal: true

module Cms
  class Site < ApplicationRecord
    self.table_name = "cms_sites"

    has_one_attached :logo

    has_many :pages,
             class_name: "Cms::Page",
             foreign_key: :site_id,
             inverse_of: :site,
             dependent: :destroy

    has_many :images,
             class_name: "Cms::Image",
             foreign_key: :site_id,
             inverse_of: :site,
             dependent: :destroy

    has_many :documents,
             class_name: "Cms::Document",
             foreign_key: :site_id,
             inverse_of: :site,
             dependent: :destroy

    has_many :sections,
             class_name: "Cms::Section",
             foreign_key: :site_id,
             inverse_of: :site,
             dependent: :destroy

    has_many :api_keys,
             class_name: "Cms::ApiKey",
             foreign_key: :site_id,
             inverse_of: :site,
             dependent: :destroy

    has_many :webhooks,
             class_name: "Cms::Webhook",
             foreign_key: :site_id,
             inverse_of: :site,
             dependent: :destroy

    validates :name, :slug, :default_locale, presence: true
    validates :slug, uniqueness: true
    validate :default_locale_is_available

    before_validation :parameterize_slug
    before_validation :normalize_locales

    scope :live, -> { where(published: true) }

    def published_pages
      pages.kept.published.ordered
    end

    def header_pages
      published_pages.header_nav
    end

    def footer_pages
      published_pages.footer_nav
    end

    def home_page
      published_pages.find_by(home: true) || published_pages.first
    end

    private

    def parameterize_slug
      self.slug = slug.to_s.parameterize if slug.present?
    end

    def normalize_locales
      self[:default_locale] = self[:default_locale].to_s.presence || I18n.default_locale.to_s
    end

    def default_locale_is_available
      supported = I18n.available_locales.map(&:to_s)
      return if supported.include?(self[:default_locale].to_s)

      errors.add(:default_locale, I18n.t("cms.errors.site.default_locale_unavailable"))
    end
  end
end
