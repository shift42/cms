# frozen_string_literal: true

module Cms
  class Section
    module Blocks
      class ImageBlock < BlockBase
        def self.kind = "image"

        settings_field :image_ids, type: :array
      end
    end
  end
end
