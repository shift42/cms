# frozen_string_literal: true

module Cms
  class Section
    module Blocks
      class CallToActionBlock < BlockBase
        def self.kind = "cta"

        settings_field :button_text, type: :string, required: true
        settings_field :button_url, type: :url,    required: true
        settings_field :alignment,  type: :select, default: "center",
                                    options: %w[left center right]
      end
    end
  end
end
