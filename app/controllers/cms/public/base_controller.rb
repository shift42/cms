# frozen_string_literal: true

module Cms
  module Public
    class BaseController < ApplicationController
      layout -> { Cms.config.public_layout }

      helper Cms::ApplicationHelper
      helper Cms::MediaHelper
      helper Cms::SitesHelper
      helper Cms::SectionsHelper
      helper Cms::PagesHelper

      rescue_from ActiveRecord::RecordNotFound, with: :render_not_found

      private

      def render_not_found
        render plain: t("cms.errors.page_not_found"), status: :not_found
      end
    end
  end
end
