# frozen_string_literal: true

module Cms
  module Admin
    class PagesController < BaseController
      include Cms::Public::PageRendering
      include Cms::Public::PagePaths

      helper Cms::ApplicationHelper
      helper Cms::MediaHelper
      helper Cms::SitesHelper
      helper Cms::SectionsHelper
      helper Cms::PagesHelper

      before_action :set_page, only: %i[show edit update destroy preview]

      def index
        pages = current_site.pages.kept.includes(:localised).ordered.to_a
        depths = page_depths(pages)

        @page_rows = if params[:q].present?
                       matching_page_rows(pages, depths)
                     else
                       flattened_page_rows(pages)
                     end
      end

      def show
        @translation_locale = requested_locale
        @subpages = @page.subpages.sort_by { |page| [page.position || 0, page.id] }
        @page_sections = @page.page_sections.ordered.includes(:section)
        @available_sections = current_site.sections
                                          .kept
                                          .global
                                          .where.not(id: @page.section_ids)
                                          .ordered
      end

      def preview
        @translation_locale = requested_locale
        @page.page_translations.find_or_initialize_by(locale: @translation_locale)
        I18n.with_locale(@translation_locale) do
          assign_public_page(site: current_site, page: @page)
          render template: "cms/public/pages/show", layout: Cms.config.public_layout
        end
      end

      def new
        @page = current_site.pages.build
        @translation_locale = requested_locale
        @page.page_translations.build(locale: @translation_locale)
        @parent_options = parent_options_for(nil)
      end

      def edit
        @translation_locale = requested_locale
        @page.page_translations.find_or_initialize_by(locale: @translation_locale)
        @parent_options = parent_options_for(@page)
      end

      def create
        @page = current_site.pages.build(page_params)
        @translation_locale = requested_locale
        purge_media_if_requested(@page)

        if @page.save
          redirect_to admin_pages_path, notice: t("cms.notices.page_created")
        else
          @parent_options = parent_options_for(nil)
          render :new, status: :unprocessable_content
        end
      end

      def update
        @translation_locale = requested_locale
        @page.assign_attributes(page_params)
        purge_media_if_requested(@page)

        if @page.save
          redirect_to admin_pages_path, notice: t("cms.notices.page_updated")
        else
          @parent_options = parent_options_for(@page)
          render :edit, status: :unprocessable_content
        end
      end

      def destroy
        @page.discard!
        redirect_to admin_pages_path, notice: t("cms.notices.page_deleted")
      end

      private

      def set_page
        @page = current_site.pages.kept.includes(
          :parent,
          :page_translations,
          { subpages: :localised },
          { page_sections: :section },
          { hero_image_attachment: :blob },
          { media_files_attachments: :blob }
        ).find(params[:id])
      end

      def page_params
        params.require(:page).permit(
          :slug,
          :parent_id,
          :position,
          :home,
          :template_key,
          :status,
          :show_in_header,
          :show_in_footer,
          :nav_group,
          :nav_order,
          :footer_order,
          :hero_image,
          media_files: [],
          page_translations_attributes: %i[id locale title seo_title seo_description]
        )
      end

      def requested_locale
        params[:locale].presence || current_site.default_locale.presence || I18n.locale.to_s
      end

      def purge_media_if_requested(page)
        page.hero_image.purge_later if params.dig(:page, :remove_hero_image) == "1"
        page.media_files.purge if params.dig(:page, :remove_media_files) == "1"
      end

      def parent_options_for(current_page)
        pages = current_site.pages.kept.ordered.includes(:localised).to_a
        depths = page_depths(pages)
        excluded_ids = current_page ? [current_page.id] + descendant_ids_for(pages, current_page.id) : []

        pages.reject { |page| excluded_ids.include?(page.id) }.map do |p|
          ["#{'— ' * depths.fetch(p.id, 0)}#{p.display_title}", p.id]
        end
      end

      def descendant_ids_for(pages, page_id)
        children_by_parent = pages.group_by(&:parent_id)
        queue = Array(children_by_parent[page_id])
        ids = []

        until queue.empty?
          page = queue.shift
          ids << page.id
          queue.concat(Array(children_by_parent[page.id]))
        end

        ids
      end

      def flattened_page_rows(pages)
        children_by_parent = pages.group_by(&:parent_id)
        rows = []

        append_page_rows(rows, children_by_parent, children_by_parent[nil], 0)
        rows
      end

      def append_page_rows(rows, children_by_parent, pages, depth)
        Array(pages).each do |page|
          rows << [page, depth]
          append_page_rows(rows, children_by_parent, children_by_parent[page.id], depth + 1)
        end
      end

      def page_depths(pages)
        pages.to_h { |page| [page.id, page.depth] }
      end

      def matching_page_rows(pages, depths)
        pages_by_id = pages.index_by(&:id)

        current_site.pages.kept.search(params[:q]).pluck(:id).filter_map do |page_id|
          page = pages_by_id[page_id]
          next unless page

          [page, depths.fetch(page.id, 0)]
        end
      end
    end
  end
end
