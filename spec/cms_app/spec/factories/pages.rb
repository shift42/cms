# frozen_string_literal: true

FactoryBot.define do
  factory :cms_page, class: "Cms::Page" do
    association :site, factory: :cms_site
    sequence(:slug) { |n| "page-#{n}" }
    template_key { "standard" }
    status { "draft" }
    show_in_header { true }
    show_in_footer { false }
    nav_group { "main" }
    nav_order { 0 }
    footer_order { 0 }
    position { 0 }

    trait :published do
      after(:create) do |page|
        next if page.page_sections.exists?

        section = create(:cms_section, site: page.site, kind: "rich_text")
        create(:cms_section_translation,
               section: section,
               locale: page.site.default_locale,
               title: "Section",
               content: "Section body")
        create(:cms_page_section, page: page, section: section, position: 0)
        page.update!(status: "published")
      end
    end
  end
end
