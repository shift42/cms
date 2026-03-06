# frozen_string_literal: true

FactoryBot.define do
  factory :cms_page_translation, class: "Cms::PageTranslation" do
    association :page, factory: :cms_page
    locale { "en" }
    sequence(:title) { |n| "Page #{n}" }
  end
end
