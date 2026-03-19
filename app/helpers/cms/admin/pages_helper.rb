# frozen_string_literal: true

module Cms
  module Admin
    module PagesHelper
      # Flatten a tree of pages (already loaded with subpages) into [page, depth] pairs.
      def flat_page_tree(pages, depth: 0, result: [])
        pages.each do |page|
          result << [page, depth]
          flat_page_tree(Array(page.subpages), depth: depth + 1, result: result) if page.subpages.loaded?
        end
        result
      end

      # Returns breadcrumb array for a page: [ancestor, ..., page]
      def breadcrumbs_for(page)
        page.ancestors + [page]
      end

      # Translation completeness: { "en" => :complete, "fr" => :missing }
      def translation_completeness(page)
        I18n.available_locales.each_with_object({}) do |locale, hash|
          translation = page.page_translations.find { |t| t.locale == locale.to_s }
          hash[locale.to_s] = translation&.title.present? ? :complete : :missing
        end
      end
    end
  end
end
