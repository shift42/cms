# frozen_string_literal: true

module Cms
  module Api
    module V1
      class BaseController < Cms::Api::BaseController
        before_action :authenticate_api_key!

        private

        def authenticate_api_key!
          site = configured_current_site || Cms::Site.live.find_by(slug: resolved_site_slug!)
          return render json: { error: t("cms.errors.api.site_not_found") }, status: :not_found unless site

          token = request.headers["Authorization"].to_s.sub(/\ABearer\s+/, "")
          @api_key = Cms::ApiKey.active.find_by(token: token, site: site)

          unless @api_key
            render json: { error: t("cms.errors.api.unauthorized") }, status: :unauthorized
            return
          end

          @resolved_site = site
          @api_key.touch_last_used!
        end
      end
    end
  end
end
