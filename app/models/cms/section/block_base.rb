# frozen_string_literal: true

module Cms
  class Section
    class BlockBase
      # Each subclass gets its own independent schema array
      def self.inherited(subclass)
        super
        subclass.instance_variable_set(:@_settings_schema, [])
      end

      def self.settings_field(name, type:, required: false, default: nil, options: nil)
        @_settings_schema ||= []
        @_settings_schema << {
          name: name.to_s,
          type: type,
          required: required,
          default: default,
          options: options
        }.compact
      end

      def self.settings_schema
        @_settings_schema || []
      end

      def self.kind
        raise NotImplementedError, "#{self} must define .kind"
      end
    end
  end
end
