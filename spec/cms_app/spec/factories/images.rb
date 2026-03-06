# frozen_string_literal: true

FactoryBot.define do
  factory :cms_image, class: "Cms::Image" do
    association :site, factory: :cms_site
    sequence(:title) { |n| "Image #{n}" }

    after(:build) do |image|
      if image.image_translations.empty?
        image.image_translations.build(locale: "en", alt_text: "Alt text", caption: "Caption")
      end

      next if image.file.attached?

      image.file.attach(
        io: File.open(Rails.root.join("public/icon.png")),
        filename: "icon.png",
        content_type: "image/png"
      )
    end
  end
end
