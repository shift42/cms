# frozen_string_literal: true

FactoryBot.define do
  factory :cms_api_key, class: "Cms::ApiKey" do
    association :site, factory: :cms_site
    sequence(:name) { |n| "Key #{n}" }
    active { true }
  end
end
