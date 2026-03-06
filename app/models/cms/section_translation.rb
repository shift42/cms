# frozen_string_literal: true

module Cms
  class SectionTranslation < ApplicationRecord
    self.table_name = "cms_section_translations"

    has_rich_text :content

    belongs_to :section,
               class_name: "Cms::Section",
               inverse_of: :translations

    validates :locale, :title, presence: true
    validates :locale, uniqueness: { scope: :section_id }
    validates :content, presence: true, if: -> { section&.kind.in?(%w[rich_text hero cta]) }

    before_validation :normalize_locale

    private

    def normalize_locale
      self.locale = locale.to_s.downcase.presence
    end
  end
end
