# frozen_string_literal: true

module Cms
  class Section
    module Blocks
      class RichTextBlock < BlockBase
        def self.kind = "rich_text"
        # No settings — title and content come from SectionTranslation
      end
    end
  end
end
