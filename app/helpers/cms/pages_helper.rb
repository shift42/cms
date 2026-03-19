# frozen_string_literal: true

module Cms
  module PagesHelper
    def render_page_template(page)
      render partial: cms_page_template_partial(page)
    end

    def cms_page_template_partial(page)
      template = "cms/public/pages/templates/#{page.template_key}"
      return template if lookup_context.exists?(template, [], true)

      "cms/public/pages/templates/standard"
    end
  end
end
