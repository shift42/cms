# frozen_string_literal: true

module Cms
  module Public
    class PreviewsController < BaseController
      include Cms::SiteResolvable
      include Cms::Public::PageRendering
      include Cms::Public::PagePaths

      def show
        page = Cms::Page.kept.includes(:site).find_by!(preview_token: params[:preview_token])
        site = page.site

        I18n.with_locale(site.default_locale) do
          assign_public_page(site: site, page: page)
          render template: "cms/public/pages/show"
        end
      end
    end
  end
end
