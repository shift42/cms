# frozen_string_literal: true

site = Cms::Site.create!(
  name: "Demo Site",
  slug: "demo"
)

[
  { slug: "home", home: true, title: "Home", body: "Welcome to CMS demo" },
  { slug: "about", title: "About", body: "About us..." },
  { slug: "contact", title: "Contact", body: "Get in touch..." }
].each do |attrs|
  page = site.pages.create!(
    slug: attrs[:slug],
    home: attrs[:home] || false,
    status: "published",
    nav_group: attrs[:nav_group] || "main"
  )
  page.page_translations.create!(locale: "en", title: attrs[:title])
end

puts "Seeded test data in cms_app!"
