# frozen_string_literal: true

module Cms
  class PublicPageContext
    attr_reader :site, :page, :header_nav_items, :footer_pages, :sections, :form_fields, :submission

    def self.build(site:, page:)
      new(site: site, page: page).tap(&:load)
    end

    def initialize(site:, page:)
      @site = site
      @page = page
    end

    def load
      @header_nav_items = load_header_nav
      @footer_pages     = site.footer_pages.includes(:localised)
      @sections         = load_sections
      @form_fields      = page.form_fields.ordered.to_a
      @submission       = page.form_submissions.build
    end

    private

    def load_sections
      page.page_sections
          .ordered
          .includes(:section)
          .filter_map do |page_section|
            section = page_section.section
            section if section.enabled? && section.kept?
          end
    end

    def load_header_nav
      site.published_pages
          .root
          .header_nav
          .includes(:localised, subpages: :localised)
          .map do |p|
            {
              page: p,
              children: p.subpages.select { |subpage| subpage.status_published? && subpage.show_in_header? }
            }
          end
    end
  end
end
