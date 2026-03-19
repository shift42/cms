# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Cms API v1 pages", type: :request do
  include Cms::Engine.routes.url_helpers

  around do |example|
    previous_page_resolver_class = Cms.config.page_resolver_class
    previous_page_serializer_class = Cms.config.api_page_serializer_class

    example.run
  ensure
    Cms.config.page_resolver_class = previous_page_resolver_class
    Cms.config.api_page_serializer_class = previous_page_serializer_class
  end

  let!(:site) { create(:cms_site, slug: "docs", published: true) }
  let!(:api_key) { create(:cms_api_key, site: site, active: true) }

  let!(:page) do
    create(:cms_page, :published, site: site, slug: "about").tap do |p|
      create(:cms_page_translation, page: p, locale: "en", title: "About")
      create(:cms_page_translation, page: p, locale: "el", title: "About EL")
    end
  end

  let!(:image) do
    create(:cms_image,
           site: site,
           title: "Section image").tap do |record|
      record.image_translations.find_by!(locale: "en").update!(alt_text: "Library alt", caption: "Library caption")
    end
  end

  let!(:hero_section) do
    create(:cms_section,
           site: site,
           kind: "hero",
           background_color: "#101010",
           cta_url: "/start").tap do |section|
      create(:cms_section_translation,
             section: section,
             locale: "en",
             title: "Hero title",
             subtitle: "Start",
             content: "Hero body")
      create(:cms_page_section, page: page, section: section, position: 0)
    end
  end

  let!(:image_section) do
    create(:cms_section, site: site, kind: "image").tap do |section|
      create(:cms_section_image, section: section, image: image, position: 0)
      create(:cms_page_section, page: page, section: section, position: 1)
    end
  end

  def auth_headers(key = api_key)
    { "Authorization" => "Bearer #{key.token}", "X-CMS-SITE-SLUG" => site.slug }
  end

  describe "GET /api/v1/pages/:slug" do
    it "returns 401 without an API key" do
      get "/api/v1/pages/about", headers: { "X-CMS-SITE-SLUG" => site.slug }
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns 401 with an invalid token" do
      get "/api/v1/pages/about", headers: { "Authorization" => "Bearer invalid", "X-CMS-SITE-SLUG" => site.slug }
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns 401 with an inactive key" do
      inactive = create(:cms_api_key, site: site, active: false)
      get "/api/v1/pages/about", headers: auth_headers(inactive)
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns the page with a valid key" do
      get "/api/v1/pages/about", headers: auth_headers
      expect(response).to have_http_status(:ok)
      payload = JSON.parse(response.body)
      expect(payload["slug"]).to eq("about")
      expect(payload["title"]).to eq("About")
      expect(payload).not_to have_key("site")
    end

    it "exposes resolved locale, available locales, settings, and kind-specific section data" do
      hero_section
      image_section

      get "/api/v1/pages/about", headers: auth_headers.merge("Accept-Language" => "el")

      expect(response).to have_http_status(:ok)

      payload = JSON.parse(response.body)
      expect(payload["resolved_locale"]).to eq("el")
      expect(payload["available_locales"]).to contain_exactly("en", "el")
      expect(payload["title"]).to eq("About EL")

      hero_payload = payload["sections"].find { |section| section["kind"] == "hero" }
      expect(hero_payload["settings"]).to eq({})
      expect(hero_payload["data"]).to include(
        "background_color" => "#101010",
        "cta_text" => "Start",
        "cta_url" => "/start"
      )
      expect(hero_payload["resolved_locale"]).to eq("en")

      image_payload = payload["sections"].find { |section| section["kind"] == "image" }
      expect(image_payload["settings"]).to eq({})
      expect(image_payload["resolved_locale"]).to eq("en")
      expect(image_payload["data"]["images"].first).to include(
        "id" => image.id,
        "title" => "Section image",
        "alt_text" => "Library alt",
        "caption" => "Library caption"
      )
      expect(image_payload["data"]["images"].first["url"]).to include("/rails/active_storage/blobs/")
    end

    it "optionally includes lightweight site metadata behind a query flag" do
      get "/api/v1/pages/about", params: { include_site: true }, headers: auth_headers

      expect(response).to have_http_status(:ok)
      payload = JSON.parse(response.body)
      expect(payload["slug"]).to eq("about")
      expect(payload["site"]).to include(
        "slug" => "docs",
        "default_locale" => site.default_locale
      )
      expect(payload["site"]).not_to have_key("pages")
    end

    it "returns 404 for unknown slug" do
      get "/api/v1/pages/nonexistent", headers: auth_headers
      expect(response).to have_http_status(:not_found)
    end

    it "touches last_used_at on the key" do
      expect { get "/api/v1/pages/about", headers: auth_headers }
        .to(change { api_key.reload.last_used_at })
    end

    it "rejects a valid token for a different site" do
      other_site = create(:cms_site, slug: "blog", published: true)
      other_key = create(:cms_api_key, site: other_site, active: true)
      headers = {
        "Authorization" => "Bearer #{other_key.token}",
        "X-CMS-SITE-SLUG" => site.slug
      }

      get "/api/v1/pages/about", headers: headers

      expect(response).to have_http_status(:unauthorized)
    end

    it "uses the configured page_resolver_class" do
      custom_result = Cms::PageResolver::Result.new(page: page, locale: "en")
      resolver = Class.new do
        def self.resolve(site:, slug:, locale:)
          raise "unexpected site" unless site.slug == "docs"
          raise "unexpected slug" unless slug == "about"
          raise "unexpected locale" unless locale == "en"

          Cms::PageResolver::Result.new(page: Cms::Page.find_by!(slug: "about"), locale: "en")
        end
      end
      stub_const("CustomPageResolver", resolver)
      Cms.config.page_resolver_class = "CustomPageResolver"

      get "/api/v1/pages/about", headers: auth_headers.merge("Accept-Language" => "en")

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["slug"]).to eq(custom_result.page.slug)
    end

    it "uses the configured api_page_serializer_class" do
      serializer = Class.new do
        def initialize(site:, page:, requested_locale:, main_app: nil)
          @main_app = main_app
          @site = site
          @page = page
          @requested_locale = requested_locale
        end

        def as_json(include_site: false)
          {
            slug: @page.slug,
            requested_locale: @requested_locale,
            site_slug: @site.slug,
            include_site: include_site
          }
        end
      end
      stub_const("CustomPageSerializer", serializer)
      Cms.config.api_page_serializer_class = "CustomPageSerializer"

      get "/api/v1/pages/about", params: { include_site: true }, headers: auth_headers

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to include(
        "slug" => "about",
        "site_slug" => "docs",
        "include_site" => true
      )
    end
  end
end
