# frozen_string_literal: true

module Cms
  module Api
    module V1
      class PagesController < BaseController
        def show
          site   = find_site!
          result = page_resolver_class.resolve(site: site, slug: params[:slug], locale: request_locale)

          return render json: { error: t("cms.errors.api.page_not_found") }, status: :not_found unless result

          I18n.with_locale(result.locale) do
            serializer = api_page_serializer(site, result.page, resolved_locale: result.locale)
            render json: serializer.as_json(include_site: truthy_param?(params[:include_site]))
          end
        end
      end
    end
  end
end
