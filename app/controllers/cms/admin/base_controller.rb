# frozen_string_literal: true

module Cms
  module Admin
    class BaseController < (Cms.config.admin_parent_controller.presence || Cms.parent_controller).constantize
      include Cms::CurrentSiteResolver

      layout -> { Cms.config.admin_layout }
      helper Cms::ApplicationHelper

      rescue_from ActiveRecord::RecordNotFound, with: :render_admin_not_found

      before_action :authorize_admin_action!
      before_action :ensure_site_access!

      private

      def current_site
        @current_site ||= configured_current_site || raise_missing_current_site!
      end

      def ensure_site_access!
        return if bootstrap_site_request? && Cms::Site.none?
        return if configured_current_site.present?

        if Cms::Site.none?
          redirect_to new_admin_site_path
          return
        end

        raise_missing_current_site!
      end

      def authorize_admin_action!
        return unless Cms.config.authorize_admin.present?
        return if Cms.config.authorize_admin.call(self)

        head :forbidden
      end

      def bootstrap_site_request?
        controller_name == "sites" && action_name.in?(%w[new create])
      end

      def render_admin_not_found
        redirect_to admin_pages_path, alert: t("cms.errors.record_not_found")
      end

      def raise_missing_current_site!
        raise t("cms.errors.current_site_required")
      end
    end
  end
end
