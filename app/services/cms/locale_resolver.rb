# frozen_string_literal: true

module Cms
  # Resolves the best available locale given a preference and a set of available locales.
  #
  # Fallback chain: requested → site default → I18n default → first available
  class LocaleResolver
    def self.resolve(requested:, site:, available:)
      new(requested: requested, site: site, available: available).resolve
    end

    def initialize(requested:, site:, available:)
      @requested = requested.to_s.presence
      @site      = site
      @available = Array(available).map(&:to_s)
    end

    def resolve
      return fallback_chain.first if @available.empty?

      fallback_chain.find { |locale| @available.include?(locale) } || @available.first
    end

    private

    def fallback_chain
      [@requested, @site.default_locale, I18n.default_locale.to_s].compact.uniq
    end
  end
end
