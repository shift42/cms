# frozen_string_literal: true

module Cms
  class SectionImage < ApplicationRecord
    self.table_name = "cms_section_images"

    belongs_to :section, class_name: "Cms::Section", inverse_of: :section_images
    belongs_to :image,   class_name: "Cms::Image"
  end
end
