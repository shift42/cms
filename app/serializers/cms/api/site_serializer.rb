# frozen_string_literal: true

module Cms
  module Api
    class SiteSerializer < BaseSerializer
      def as_json(include_pages: true)
        payload = site_attributes(resolved_locale: requested_locale)
        return payload unless include_pages

        payload.merge(
          pages: published_pages.map do |page|
            serialize_site_page(page)
          end
        )
      end

      private

      def published_pages
        site.published_pages.includes(:page_translations, { hero_image_attachment: :blob })
      end

      def serialize_site_page(page)
        locale = resolved_content_locale(page.page_translations.map(&:locale))
        translation = page.page_translations.find { |record| record.locale == locale }

        {
          id: page.id,
          template_key: page.template_key,
          status: page.status,
          resolved_locale: locale,
          available_locales: page.page_translations.map(&:locale),
          title: translation&.title.presence || page.slug.to_s.humanize,
          slug: page.slug,
          path: page.public_path,
          home: page.home,
          nav_group: page.nav_group,
          show_in_header: page.show_in_header,
          show_in_footer: page.show_in_footer,
          hero_image_url: attachment_path(page.hero_image)
        }
      end
    end
  end
end
