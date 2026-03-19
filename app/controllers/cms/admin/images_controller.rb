# frozen_string_literal: true

module Cms
  module Admin
    class ImagesController < BaseController
      before_action :set_image, only: %i[edit update destroy]

      def index
        @images = current_site.images.includes(:localised).ordered
      end

      def new
        @image = current_site.images.build
        @translation_locale = requested_locale
        @image.image_translations.build(locale: @translation_locale)
      end

      def edit
        @translation_locale = requested_locale
        @image.image_translations.find_or_initialize_by(locale: @translation_locale)
      end

      def create
        @image = current_site.images.build(image_params)
        @translation_locale = requested_locale

        if @image.save
          redirect_to admin_images_path, notice: t("cms.notices.image_uploaded")
        else
          render :new, status: :unprocessable_content
        end
      end

      def update
        @translation_locale = requested_locale
        @image.assign_attributes(image_params)

        if @image.save
          redirect_to admin_images_path, notice: t("cms.notices.image_updated")
        else
          render :edit, status: :unprocessable_content
        end
      end

      def destroy
        @image.file.purge_later
        @image.destroy
        redirect_to admin_images_path, notice: t("cms.notices.image_deleted")
      end

      private

      def set_image
        @image = current_site.images.includes(:image_translations, :localised).find(params[:id])
      end

      def image_params
        params.fetch(:cms_image, params.fetch(:image, ActionController::Parameters.new))
              .permit(:title, :file, image_translations_attributes: %i[id locale alt_text caption])
      end

      def requested_locale
        params[:locale].presence || current_site.default_locale.presence || I18n.locale.to_s
      end
    end
  end
end
