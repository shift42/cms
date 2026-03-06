# frozen_string_literal: true

module Cms
  module SectionsHelper
    def cms_sections(kind:, site: nil)
      target_site = site || (defined?(@site) ? @site : nil)
      return Cms::Section.none unless target_site

      target_site.sections.enabled.by_kind(kind).includes(:translations,
                                                          section_images: { image: { file_attachment: :blob } }).ordered
    end

    # Renders the partial registered for the section's kind.
    # In non-production, renders an error notice for unknown kinds.
    # In production, raises so the error is surfaced properly.
    def render_section(section)
      partial = Cms::Section::KindRegistry.partial_for(section.kind)
      render partial, section: section
    rescue Cms::Section::KindRegistry::UnknownKindError => e
      raise e if Rails.env.production?

      content_tag(:div, e.message, class: "cms-section--unknown", style: "color:red;padding:1em;border:1px solid red;")
    end
  end
end
