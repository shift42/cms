# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Cms::Page search scope", type: :model do
  let!(:site) { create(:cms_site) }

  before do
    p1 = create(:cms_page, site: site, slug: "hello-world")
    create(:cms_page_translation, page: p1, locale: "en", title: "Hello World")

    p2 = create(:cms_page, site: site, slug: "about-us")
    create(:cms_page_translation, page: p2, locale: "en", title: "About Us")

    p3 = create(:cms_page, site: site, slug: "cafe")
    create(:cms_page_translation, page: p3, locale: "en", title: "Café Corner")
  end

  it "finds pages by title" do
    results = site.pages.search("hello")
    expect(results.map(&:slug)).to include("hello-world")
    expect(results.map(&:slug)).not_to include("about-us")
  end

  it "finds pages by slug" do
    results = site.pages.search("about")
    expect(results.map(&:slug)).to include("about-us")
  end

  it "is case-insensitive" do
    results = site.pages.search("HELLO")
    expect(results.map(&:slug)).to include("hello-world")
  end

  it "handles accented characters (unaccent)" do
    results = site.pages.search("cafe")
    expect(results.map(&:slug)).to include("cafe")
  end
end
