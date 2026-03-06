# frozen_string_literal: true

module Cms
  class PageResolver
    Result = Struct.new(:page, :locale)

    # Finds a published page by slug within a site and resolves the best
    # available locale using the fallback chain:
    #   requested locale → site.default_locale → I18n.default_locale → any
    #
    # @param site [Cms::Site]
    # @param slug [String, nil] nil or blank resolves the home page; nested
    #   paths such as "about/history" resolve by ancestor chain
    # @param locale [String, nil] the caller's preferred locale
    # @return [Result, nil]
    def self.resolve(site:, slug: nil, locale: nil)
      new(site: site, slug: slug, locale: locale).resolve
    end

    def initialize(site:, slug:, locale:)
      @site   = site
      @slug   = slug.to_s
      @locale = locale.to_s.presence
    end

    def resolve
      page = find_page
      return nil unless page

      Result.new(page: page, locale: resolved_locale_for(page))
    end

    private

    attr_reader :site, :slug, :locale

    def normalized_segments
      @normalized_segments ||= slug.to_s.split("/").filter_map do |segment|
        normalized = segment.to_s.parameterize
        normalized if normalized.present?
      end
    end

    def find_page
      scope = site.published_pages
                  .includes(
                    :page_translations,
                    :localised,
                    { page_sections: :section },
                    :form_fields,
                    { hero_image_attachment: :blob }
                  )

      if normalized_segments.empty?
        scope.find_by(home: true) || scope.first
      else
        page = scope.find_by(slug: normalized_segments.last)
        return unless page
        return page if page.public_path_segments == normalized_segments

        nil
      end
    end

    def resolved_locale_for(page)
      Cms::LocaleResolver.resolve(
        requested: @locale,
        site: @site,
        available: page.page_translations.map(&:locale)
      )
    end
  end
end
