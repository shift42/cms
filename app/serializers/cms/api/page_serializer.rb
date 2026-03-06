# frozen_string_literal: true

module Cms
  module Api
    class PageSerializer < BaseSerializer
      def initialize(site:, page:, requested_locale:, main_app:)
        super(site: site, requested_locale: requested_locale, main_app: main_app)
        @page = page
      end

      def as_json(include_site: false)
        payload = serialize_page
        return payload unless include_site

        payload.merge(
          site: Cms.api_site_serializer_class.new(
            site: site,
            requested_locale: payload[:resolved_locale],
            main_app: main_app
          ).as_json(include_pages: false)
        )
      end

      private

      attr_reader :page

      def serialize_page
        locale = resolved_content_locale(page.page_translations.map(&:locale))
        translation = page.page_translations.find { |record| record.locale == locale }

        base_page_attributes(locale, translation).merge(
          meta_title: page_meta_title(translation),
          meta_description: translation&.seo_description,
          media_files: page.media_files.map { |file| serialize_media(file) },
          sections: serialize_page_sections(locale)
        )
      end

      def serialize_page_sections(locale)
        page.page_sections.ordered.includes(:section).filter_map do |page_section|
          section = page_section.section
          next unless section.enabled?

          serialize_section(section, position: page_section.position, requested_locale: locale)
        end
      end

      def serialize_section(section, position:, requested_locale:)
        locale = resolved_content_locale_for_section(section, requested_locale)
        translation = section.translation_for(locale)

        {
          id: section.id,
          kind: section.kind,
          position: position,
          resolved_locale: locale,
          available_locales: section.available_locales,
          title: translation.respond_to?(:title) ? translation.title : nil,
          body: translation.respond_to?(:content) ? translation.content.to_s : "",
          settings: {},
          data: serialize_section_data(section, requested_locale: locale)
        }
      end

      def resolved_content_locale_for_section(section, requested_locale)
        available_locales = section.available_locales
        if available_locales.empty? && section.kind == "image"
          available_locales = section.images.flat_map { |image| image.image_translations.map(&:locale) }.uniq
        end

        Cms::LocaleResolver.resolve(
          requested: requested_locale,
          site: site,
          available: available_locales
        )
      end

      def serialize_section_data(section, requested_locale:)
        case section.kind
        when "hero"
          {
            background_color: section.background_color,
            cta_text: section.translation_for(requested_locale)&.subtitle,
            cta_url: section.cta_url
          }
        when "cta"
          {
            button_text: section.translation_for(requested_locale)&.subtitle,
            button_url: section.button_url,
            alignment: section.alignment.presence || "center"
          }
        when "image"
          image_payloads = serialize_section_images(section, requested_locale)
          {
            images: image_payloads
          }
        else
          {}
        end
      end

      def serialize_section_images(section, requested_locale)
        section.image_assets.filter_map do |image|
          locale = Cms::LocaleResolver.resolve(
            requested: requested_locale,
            site: site,
            available: image.image_translations.map(&:locale)
          )
          translation = image.image_translations.find { |record| record.locale == locale }

          {
            id: image.id,
            title: image.title,
            alt_text: translation&.alt_text,
            caption: translation&.caption,
            url: attachment_path(image.file)
          }
        end
      end

      def base_page_attributes(locale, translation)
        {
          id: page.id,
          template_key: page.template_key,
          status: page.status,
          resolved_locale: locale,
          available_locales: page.page_translations.map(&:locale),
          title: translation_title(translation),
          slug: page.slug,
          path: page.public_path,
          hero_image_url: attachment_path(page.hero_image)
        }
      end

      def translation_title(translation)
        translation&.title.presence || page.slug.to_s.humanize
      end

      def page_meta_title(translation)
        translation&.seo_title.presence || translation_title(translation)
      end
    end
  end
end
