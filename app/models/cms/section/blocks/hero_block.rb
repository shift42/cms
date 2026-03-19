# frozen_string_literal: true

module Cms
  class Section
    module Blocks
      class HeroBlock < BlockBase
        def self.kind = "hero"

        settings_field :background_color, type: :color, default: "#ffffff"
        settings_field :cta_url,          type: :url
      end
    end
  end
end
