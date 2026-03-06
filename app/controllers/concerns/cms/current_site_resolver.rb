# frozen_string_literal: true

module Cms
  module CurrentSiteResolver
    extend ActiveSupport::Concern

    private

    def configured_current_site
      resolver = Cms.config.current_site_resolver
      site = resolver.call(self) if resolver
      return site if site.is_a?(Cms::Site)

      nil
    end
  end
end
