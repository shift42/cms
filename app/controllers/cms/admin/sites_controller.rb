# frozen_string_literal: true

module Cms
  module Admin
    class SitesController < BaseController
      before_action :redirect_bootstrap_requests_when_site_available, only: %i[new create]

      def new
        @site = Cms::Site.new(default_locale: I18n.default_locale.to_s, published: true)
      end

      def create
        @site = Cms::Site.new(site_params)
        purge_media_if_requested(@site)

        if @site.save
          redirect_to admin_site_path, notice: t("cms.notices.site_created")
        else
          render :new, status: :unprocessable_content
        end
      end

      def show
        @site = current_site
      end

      def edit
        @site = current_site
      end

      def update
        @site = current_site
        purge_media_if_requested(@site)

        if @site.update(site_params)
          redirect_to admin_site_path, notice: t("cms.notices.site_updated")
        else
          render :edit, status: :unprocessable_content
        end
      end

      private

      def site_params
        params.require(:site).permit(:name, :slug, :published, :default_locale, :logo)
      end

      def purge_media_if_requested(site)
        site.logo.purge_later if params.dig(:site, :remove_logo) == "1"
      end

      def redirect_bootstrap_requests_when_site_available
        return unless Cms::Site.exists?
        return redirect_to(edit_admin_site_path) if configured_current_site.present?

        raise_missing_current_site!
      end
    end
  end
end
