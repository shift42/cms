# frozen_string_literal: true

module Cms
  class PageSection < ApplicationRecord
    self.table_name = "cms_page_sections"

    belongs_to :page, class_name: "Cms::Page", inverse_of: :page_sections
    belongs_to :section, class_name: "Cms::Section", inverse_of: :page_sections

    validates :section_id, uniqueness: { scope: :page_id }
    validate :section_site_matches_page
    validate :global_sections_cannot_become_orphaned, on: :destroy

    scope :ordered, -> { order(:position, :id) }

    after_destroy :destroy_orphaned_section

    private

    def section_site_matches_page
      return unless page && section
      return if page.site_id == section.site_id

      errors.add(:section, :invalid)
    end

    def global_sections_cannot_become_orphaned
      return unless section&.global?
      return if section.page_sections.where.not(id: id).exists?

      errors.add(:base, I18n.t("cms.errors.section.global_section_requires_attachment"))
      throw :abort
    end

    def destroy_orphaned_section
      return unless Cms.config.auto_destroy_orphaned_sections
      return if section.global?
      return if section.page_sections.exists?

      section.destroy
    end
  end
end
