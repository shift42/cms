# frozen_string_literal: true

module Cms
  module SitesHelper
    def site_favicon_tag(site)
      return unless site.logo.attached?

      favicon_link_tag(cms_attachment_path(site.logo))
    end
  end
end
