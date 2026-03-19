# frozen_string_literal: true

module Cms
  module Public
    module PageRendering
      extend ActiveSupport::Concern

      private

      def assign_public_page(site:, page:)
        ctx = Cms::PublicPageContext.build(site: site, page: page)

        @site              = ctx.site
        @page              = ctx.page
        @header_nav_items  = ctx.header_nav_items
        @footer_pages      = ctx.footer_pages
        @sections          = ctx.sections
        @form_fields       = ctx.form_fields
        @submission        = ctx.submission if @submission.nil?
      end
    end
  end
end
