# frozen_string_literal: true

module Cms
  class Image < ApplicationRecord
    self.table_name = "cms_images"

    PERMITTED_CONTENT_TYPES = [
      "image/jpeg",
      "image/png",
      "image/webp",
      "image/gif",
      "image/svg+xml",
      "image/tiff"
    ].freeze

    belongs_to :site, class_name: "Cms::Site", inverse_of: :images
    has_one_attached :file
    has_many :section_images,
             class_name: "Cms::SectionImage",
             foreign_key: :image_id,
             inverse_of: :image,
             dependent: :destroy

    has_many :image_translations,
             class_name: "Cms::ImageTranslation",
             foreign_key: :image_id,
             inverse_of: :image,
             dependent: :destroy

    accepts_nested_attributes_for :image_translations

    has_one :localised, -> { where(locale: I18n.locale.to_s) },
            class_name: "Cms::ImageTranslation",
            foreign_key: :image_id,
            inverse_of: :image

    delegate :alt_text, :caption, to: :localised, allow_nil: true

    validates :title, :file, presence: true
    validate :file_must_be_an_image

    scope :ordered, -> { order(created_at: :desc) }

    def display_title
      title.presence || file.filename.to_s
    end

    def variant(dimensions)
      file.variant(resize_to_limit: dimensions.split("x").map(&:to_i))
    end

    private

    def file_must_be_an_image
      return unless file.attached?
      return if PERMITTED_CONTENT_TYPES.include?(file.blob.content_type)

      errors.add(:file, I18n.t("cms.errors.image.invalid_file_type", default: "must be a valid image file"))
    end
  end
end
