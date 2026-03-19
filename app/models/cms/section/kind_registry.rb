# frozen_string_literal: true

module Cms
  class Section
    module KindRegistry
      BUILT_IN_KINDS = %w[rich_text image hero cta].freeze

      class UnknownKindError < StandardError; end

      @registry = {}

      class << self
        # Register a section kind.
        #
        # @param kind [String, Symbol]
        # @param partial [String, nil] override the default partial path
        # @param block_class [Class, nil] block class that defines settings_schema
        def register(kind, partial: nil, block_class: nil)
          @registry[kind.to_s] = {
            partial: partial.presence || "cms/sections/kinds/#{kind}",
            block_class: block_class
          }
        end

        # @param kind [String]
        # @return [String] partial path
        # @raise [Cms::Section::KindRegistry::UnknownKindError]
        def partial_for(kind)
          entry_for(kind)[:partial]
        end

        # @param kind [String]
        # @return [Class, nil] block class or nil if not set
        def block_class_for(kind)
          entry_for(kind)[:block_class]
        end

        # @return [Array<String>]
        def registered_kinds
          @registry.keys
        end

        # @param kind [String, Symbol]
        # @return [Boolean]
        def registered?(kind)
          @registry.key?(kind.to_s)
        end

        # For testing — resets to an empty registry
        def reset!
          @registry = {}
        end

        private

        def entry_for(kind)
          @registry.fetch(kind.to_s) do
            raise UnknownKindError,
                  "No renderer registered for section kind: #{kind.inspect}. " \
                  "Registered kinds: #{@registry.keys.inspect}"
          end
        end
      end
    end
  end
end
