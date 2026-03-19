# frozen_string_literal: true

FactoryBot.define do
  factory :cms_site, class: "Cms::Site" do
    sequence(:name) { |n| "Site #{n}" }
    sequence(:slug) { |n| "site-#{n}" }
    published { true }
    default_locale { "en" }
  end
end
