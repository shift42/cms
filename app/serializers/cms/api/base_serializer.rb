# frozen_string_literal: true

module Cms
  module Api
    class BaseSerializer
      def initialize(site:, requested_locale:, main_app:)
        @site = site
        @requested_locale = requested_locale
        @main_app = main_app
      end

      private

      attr_reader :site, :requested_locale, :main_app

      def resolved_content_locale(available_locales)
        Cms::LocaleResolver.resolve(
          requested: requested_locale,
          site: site,
          available: available_locales
        )
      end

      def attachment_path(attachment)
        return nil unless attachment.attached?

        main_app.rails_blob_path(attachment, only_path: true)
      end

      def serialize_media(file)
        {
          filename: file.filename.to_s,
          url: attachment_path(file)
        }
      end

      def site_attributes(resolved_locale:)
        {
          id: site.id,
          name: site.name,
          slug: site.slug,
          default_locale: site.default_locale,
          resolved_locale: resolved_locale,
          available_locales: I18n.available_locales.map(&:to_s),
          logo_url: attachment_path(site.logo),
          favicon_url: attachment_path(site.logo)
        }
      end
    end
  end
end
