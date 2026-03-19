# frozen_string_literal: true

module Cms
  module Public
    module PagePaths
      extend ActiveSupport::Concern

      included do
        helper_method :public_site_path_for, :public_site_page_path_for
      end

      private

      def routed_without_site_slug?
        params[:site_slug].blank? && (request.headers["X-CMS-SITE-SLUG"].present? || request.subdomains.first.present?)
      end

      def public_site_path_for(site)
        routed_without_site_slug? ? current_site_path : site_path(site.slug)
      end

      def public_site_page_path_for(site, page)
        return public_site_path_for(site) if page.home?

        page_path = page.public_path

        routed_without_site_slug? ? current_site_page_path(page_path) : site_page_path(site.slug, page_path)
      end
    end
  end
end
