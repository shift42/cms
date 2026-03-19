# frozen_string_literal: true

module Cms
  module SiteResolvable
    extend ActiveSupport::Concern
    include Cms::CurrentSiteResolver

    private

    def find_site!
      return @resolved_site if defined?(@resolved_site) && @resolved_site
      return configured_current_site if configured_current_site

      Cms::Site.live.find_by!(slug: resolved_site_slug!)
    end

    def resolved_site_slug!
      slug = params[:site_slug].presence ||
             request.headers["X-CMS-SITE-SLUG"].presence ||
             request.subdomains.first.presence
      normalized = slug.to_s.parameterize
      raise ActiveRecord::RecordNotFound, I18n.t("cms.errors.site_slug_not_provided") if normalized.blank?

      normalized
    end
  end
end
