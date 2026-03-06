# frozen_string_literal: true

module Cms
  class ImageTranslation < ApplicationRecord
    self.table_name = "cms_image_translations"

    belongs_to :image,
               class_name: "Cms::Image",
               inverse_of: :image_translations

    validates :locale, :alt_text, presence: true
    validates :locale, uniqueness: { scope: :image_id }

    before_validation :normalize_locale

    private

    def normalize_locale
      self.locale = locale.to_s.downcase.presence
    end
  end
end
