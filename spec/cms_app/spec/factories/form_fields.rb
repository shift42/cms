# frozen_string_literal: true

FactoryBot.define do
  factory :cms_form_field, class: "Cms::FormField" do
    association :page, factory: :cms_page
    kind { "text" }
    sequence(:label) { |n| "Field #{n}" }
    sequence(:field_name) { |n| "field_#{n}" }
    required { false }
    position { 0 }
    options { [] }
  end
end
