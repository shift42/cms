# frozen_string_literal: true

module Cms
  module Admin
    class SectionsController < BaseController
      include PageScopedSections

      before_action :set_page, if: :page_scoped_request?
      before_action :set_section, only: %i[show edit update destroy]

      def index
        @sections = current_site.sections.kept.global.includes(:translations, :section_images).ordered
      end

      def show
        @translation_locale = requested_locale
      end

      def new
        @section = current_site.sections.build(kind: params[:kind].presence || "rich_text", global: !@page)
        @translation_locale = requested_locale
        @section.build_missing_locale_translations
      end

      def edit
        @translation_locale = requested_locale
        @section.build_missing_locale_translations
      end

      def create
        @section = current_site.sections.build(section_params)
        @section.global = !@page
        @translation_locale = requested_locale

        if @section.save
          sync_section_images(@section)
          if turbo_page_scoped_request?
            attach_to_page!
            flash.now[:notice] = success_notice_for(:create)
            load_page_show_context
            render :page_update
          else
            attach_to_page! if @page
            redirect_to after_save_path, notice: success_notice_for(:create)
          end
        else
          render :new, status: :unprocessable_content
        end
      end

      def update
        @translation_locale = requested_locale
        @section.assign_attributes(section_params)

        if @section.save
          sync_section_images(@section)
          if turbo_page_scoped_request?
            flash.now[:notice] = success_notice_for(:update)
            load_page_show_context
            render :page_update
          else
            redirect_to after_save_path, notice: success_notice_for(:update)
          end
        else
          render :edit, status: :unprocessable_content
        end
      end

      def destroy
        if turbo_page_scoped_request?
          @page.page_sections.find_by!(section_id: @section.id).destroy
          flash.now[:notice] = success_notice_for(:destroy)
          load_page_show_context
          render :page_update
        elsif @page
          @page.page_sections.find_by!(section_id: @section.id).destroy
        else
          @section.discard!
        end

        redirect_to after_destroy_path, notice: success_notice_for(:destroy) unless performed?
      end

      def sort
        ids = params[:page_section_ids].to_a.map(&:to_i)
        ids.each_with_index do |id, index|
          @page.page_sections.find(id).update!(position: index)
        end
        head :ok
      end

      def attach
        section = current_site.sections.global.find(params[:section_id])
        @page.page_sections.find_or_create_by!(section: section) do |page_section|
          page_section.position = next_position
        end

        if turbo_page_scoped_request?
          flash.now[:notice] = t("cms.notices.section_attached")
          load_page_show_context
          render :page_update
        else
          redirect_to admin_page_path(@page), notice: t("cms.notices.section_attached")
        end
      end

      private

      def set_section
        @section = current_site.sections.kept.includes(:translations).find(params[:id])
      end

      def requested_locale
        params[:locale].presence ||
          section_locale.presence ||
          current_site.default_locale.presence ||
          I18n.locale.to_s
      end

      def section_locale
        return unless @section

        @section.available_locales.first
      end

      def section_kind
        params.dig(:section, :kind).presence || @section&.kind || params[:kind].presence || "rich_text"
      end

      def section_params
        permitted = %i[global enabled]
        permitted.unshift(:kind) unless @section&.persisted?
        permitted += permitted_settings_keys
        permitted << { translations_attributes: %i[id locale title subtitle content] }

        params.require(:section).permit(*permitted)
      end

      def permitted_settings_keys
        case section_kind
        when "hero" then %i[background_color cta_url]
        when "cta"  then %i[button_url alignment]
        else []
        end
      end

      def sync_section_images(section)
        return unless section_kind == "image"

        ids = params.dig(:section, :image_ids).to_a.compact_blank.map(&:to_i)
        section.section_images.destroy_all
        ids.each_with_index do |image_id, index|
          section.section_images.create!(image_id: image_id, position: index)
        end
      end

      def after_save_path
        @page ? admin_page_path(@page, locale: @translation_locale) : admin_sections_path(locale: @translation_locale)
      end

      def after_destroy_path
        @page ? admin_page_path(@page, locale: params[:locale]) : admin_sections_path(locale: params[:locale])
      end

      def success_notice_for(action)
        return t("cms.notices.section_added")   if action == :create  && @page
        return t("cms.notices.section_removed") if action == :destroy && @page

        {
          create: t("cms.notices.section_created"),
          update: t("cms.notices.section_updated"),
          destroy: t("cms.notices.section_deleted")
        }.fetch(action)
      end
    end
  end
end
