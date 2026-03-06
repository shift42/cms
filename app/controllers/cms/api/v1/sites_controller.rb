# frozen_string_literal: true

module Cms
  module Api
    module V1
      class SitesController < BaseController
        def show
          site = find_site!
          resolved_locale = request_locale.presence || site.default_locale

          I18n.with_locale(resolved_locale) do
            render json: api_site_serializer(site, resolved_locale: resolved_locale).as_json
          end
        end
      end
    end
  end
end
