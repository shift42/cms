# frozen_string_literal: true

FactoryBot.define do
  factory :cms_section, class: "Cms::Section" do
    association :site, factory: :cms_site
    kind { "rich_text" }
    global { false }
    enabled { true }
    settings { {} }

    trait :hero do
      kind { "hero" }
      settings { { "background_color" => "#ffffff", "cta_url" => "https://example.com/start" } }
    end

    trait :cta do
      kind { "cta" }
      settings { { "button_url" => "https://example.com", "alignment" => "center" } }
    end

    trait :image do
      kind { "image" }
    end

    trait :global do
      global { true }
    end
  end

  factory :cms_section_translation, class: "Cms::SectionTranslation" do
    association :section, factory: :cms_section
    locale { "en" }
    title { "Section title" }

    trait :with_subtitle do
      subtitle { "Section subtitle" }
    end

    transient do
      content { nil }
    end

    after(:build) do |translation, evaluator|
      translation.content = evaluator.content if evaluator.content.present?
    end
  end

  factory :cms_section_image, class: "Cms::SectionImage" do
    association :section, factory: :cms_section
    association :image,   factory: :cms_image
    position { 0 }
  end

  factory :cms_page_section, class: "Cms::PageSection" do
    association :page,    factory: :cms_page
    association :section, factory: :cms_section
    position { 0 }

    after(:build) do |page_section|
      page_section.section.site = page_section.page.site
    end
  end
end
