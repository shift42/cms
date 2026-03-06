# frozen_string_literal: true

module Cms
  module MediaHelper
    def cms_image_tag(image, rendition: nil, **)
      return "" unless image&.file&.attached?

      if rendition && Cms.config.image_renditions&.key?(rendition)
        dimensions = Cms.config.image_renditions[rendition]
        width, height = dimensions.split("x").map(&:to_i)
        variant = image.file.variant(resize_to_limit: [width, height]).processed
        image_tag(main_app.rails_representation_path(variant, only_path: true),
                  alt: image.alt_text.presence || image.display_title,
                  **)
      else
        image_tag(main_app.rails_blob_path(image.file, only_path: true),
                  alt: image.alt_text.presence || image.display_title,
                  **)
      end
    end

    def cms_document_url(document)
      return nil unless document&.file&.attached?

      url_for(document.file)
    end
  end
end
