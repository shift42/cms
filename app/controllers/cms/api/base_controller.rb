# frozen_string_literal: true

module Cms
  module Api
    class BaseController < ApplicationController
      include Cms::SiteResolvable

      layout false

      rescue_from ActiveRecord::RecordNotFound, with: :render_not_found_json

      private

      def render_not_found_json
        render json: { error: t("cms.errors.api.page_not_found") }, status: :not_found
      end

      def api_site_serializer(site, resolved_locale:)
        Cms.api_site_serializer_class.new(
          site: site,
          requested_locale: resolved_locale,
          main_app: main_app
        )
      end

      def api_page_serializer(site, page, resolved_locale:)
        Cms.api_page_serializer_class.new(
          site: site,
          page: page,
          requested_locale: resolved_locale,
          main_app: main_app
        )
      end

      def truthy_param?(value)
        ActiveModel::Type::Boolean.new.cast(value)
      end

      def request_locale
        params[:locale].presence ||
          request.headers["Accept-Language"].to_s.split(",").first&.strip
      end
    end
  end
end
