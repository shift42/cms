# frozen_string_literal: true

module Cms
  class PageTranslation < ApplicationRecord
    self.table_name = "cms_page_translations"

    belongs_to :page,
               class_name: "Cms::Page",
               inverse_of: :page_translations

    validates :locale, :title, presence: true
    validates :locale, uniqueness: { scope: :page_id }

    before_validation :normalize_locale

    private

    def normalize_locale
      self.locale = locale.to_s.downcase.presence
    end
  end
end
