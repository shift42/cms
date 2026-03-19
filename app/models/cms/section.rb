# frozen_string_literal: true

module Cms
  class Section < ApplicationRecord
    include ::Discard::Model

    self.table_name = "cms_sections"

    attribute :settings, default: -> { {} }
    store_accessor :settings, :background_color, :cta_url, :button_url, :alignment

    belongs_to :site,
               class_name: "Cms::Site",
               inverse_of: :sections

    has_many :page_sections,
             class_name: "Cms::PageSection",
             foreign_key: :section_id,
             inverse_of: :section,
             dependent: :destroy

    has_many :pages,
             through: :page_sections,
             source: :page

    has_many :translations,
             class_name: "Cms::SectionTranslation",
             foreign_key: :section_id,
             inverse_of: :section,
             dependent: :destroy

    has_one :localised, -> { where(locale: I18n.locale.to_s) },
            class_name: "Cms::SectionTranslation",
            foreign_key: :section_id,
            inverse_of: :section

    has_many :section_images,
             -> { order(:position) },
             class_name: "Cms::SectionImage",
             foreign_key: :section_id,
             inverse_of: :section,
             dependent: :destroy

    has_many :images,
             through: :section_images,
             source: :image,
             class_name: "Cms::Image"

    accepts_nested_attributes_for :translations

    validates :kind, presence: true, inclusion: { in: -> { Cms::Section::KindRegistry.registered_kinds } }
    validates :alignment, inclusion: { in: %w[left center right] }, allow_blank: true

    scope :ordered,  -> { order(:kind, :id) }
    scope :enabled,  -> { where(enabled: true) }
    scope :global,   -> { where(global: true) }
    scope :local,    -> { where(global: false) }
    scope :by_kind,  ->(kind) { where(kind: kind) }

    delegate :title, :subtitle, :content, to: :localised, allow_nil: true

    def cta_text    = localised&.subtitle
    def button_text = localised&.subtitle

    def build_missing_locale_translations
      present = if translations.loaded?
                  translations.target.map(&:locale)
                elsif new_record?
                  []
                else
                  translations.pluck(:locale)
                end
      I18n.available_locales.map(&:to_s).each do |locale|
        translations.build(locale: locale) unless present.include?(locale)
      end
    end

    def image_assets
      images.includes(file_attachment: :blob)
    end

    def available_locales
      translations.map(&:locale)
    end

    def translation_for(locale)
      translations.find { |t| t.locale == locale.to_s }
    end

    def settings
      super || {}
    end
  end
end
