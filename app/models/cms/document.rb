# frozen_string_literal: true

module Cms
  class Document < ApplicationRecord
    self.table_name = "cms_documents"

    WORD_CONTENT_TYPES = [
      "application/msword",
      "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
      "application/vnd.ms-excel",
      "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
      "application/vnd.ms-powerpoint",
      "application/vnd.openxmlformats-officedocument.presentationml.presentation"
    ].freeze

    PERMITTED_CONTENT_TYPES = [
      "application/pdf",
      "image/png",
      "image/jpeg",
      "image/tiff",
      "text/plain",
      "text/csv",
      "application/zip",
      "application/x-zip-compressed"
    ] + WORD_CONTENT_TYPES

    belongs_to :site, class_name: "Cms::Site", inverse_of: :documents
    has_one_attached :file

    validates :title, :file, presence: true
    validate :file_must_be_a_supported_document

    scope :ordered, -> { order(:title) }

    def display_title
      title
    end

    private

    def file_must_be_a_supported_document
      return unless file.attached?
      return if PERMITTED_CONTENT_TYPES.include?(file.blob.content_type)

      errors.add(:file, I18n.t("cms.errors.document.invalid_file_type", default: "must be a supported document file"))
    end
  end
end
