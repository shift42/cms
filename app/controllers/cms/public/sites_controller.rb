# frozen_string_literal: true

module Cms
  module Public
    class SitesController < BaseController
      include Cms::SiteResolvable
      include Cms::Public::PageRendering
      include Cms::Public::PagePaths

      def show
        site = find_site!
        result = find_page_for_show!(site)

        return render_not_found unless result

        I18n.with_locale(result.locale) do
          assign_public_page(site: site, page: result.page)
          render template: "cms/public/pages/show"
        end
      end

      private

      def find_page_for_show!(site)
        page_resolver_class.resolve(
          site: site,
          slug: params[:slug],
          locale: I18n.locale.to_s
        )
      end

      def render_not_found
        render plain: t("cms.errors.page_not_found"), status: :not_found
      end
    end
  end
end
