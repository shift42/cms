# frozen_string_literal: true

module Cms
  module Admin
    module PageScopedSections
      extend ActiveSupport::Concern

      private

      def set_page
        @page = current_site.pages.find(params[:page_id])
      end

      def page_scoped_request?
        params[:page_id].present?
      end

      def turbo_page_scoped_request?
        page_scoped_request? && (turbo_frame_request? || request.format.turbo_stream?)
      end

      def attach_to_page!
        @page.page_sections.create!(section: @section, position: next_position)
      end

      def next_position
        @page.page_sections.maximum(:position).to_i + 1
      end

      def load_page_show_context
        @translation_locale = requested_locale
        @subpages = @page.subpages.sort_by { |page| [page.position || 0, page.id] }
        @page_sections = @page.page_sections.ordered.includes(:section)
        @available_sections = current_site.sections
                                          .kept
                                          .global
                                          .where.not(id: @page.section_ids)
                                          .ordered
      end
    end
  end
end
