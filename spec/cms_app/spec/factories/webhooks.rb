# frozen_string_literal: true

FactoryBot.define do
  factory :cms_webhook, class: "Cms::Webhook" do
    association :site, factory: :cms_site
    sequence(:url) { |n| "https://example#{n}.test/webhooks/cms" }
    events { ["page.published"] }
    active { true }
    secret { "secret-token" }
  end
end
