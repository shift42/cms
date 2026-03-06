# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Cms API v1 sites", type: :request do
  around do |example|
    previous_site_serializer_class = Cms.config.api_site_serializer_class
    example.run
  ensure
    Cms.config.api_site_serializer_class = previous_site_serializer_class
  end

  let!(:site) { create(:cms_site, name: "Docs", slug: "docs", published: true) }
  let!(:api_key) { create(:cms_api_key, site: site) }

  let(:logo_upload) do
    Rack::Test::UploadedFile.new(
      Rails.root.join("public/icon.png"),
      "image/png"
    )
  end

  def auth_headers(key = api_key)
    {
      "Authorization" => "Bearer #{key.token}",
      "X-CMS-SITE-SLUG" => site.slug
    }
  end

  before do
    create(:cms_page, :published, site: site, slug: "home", home: true).tap do |page|
      create(:cms_page_translation, page: page, locale: "en", title: "Home")
    end
    create(:cms_page, :published, site: site, slug: "about").tap do |page|
      create(:cms_page_translation, page: page, locale: "en", title: "About")
    end
    about_page = Cms::Page.find_by!(site: site, slug: "about")
    create(:cms_page, :published, site: site, slug: "history", parent: about_page).tap do |page|
      create(:cms_page_translation, page: page, locale: "en", title: "History")
    end
    site.logo.attach(logo_upload)
  end

  describe "GET /api/v1/sites/:site_slug" do
    it "returns site data with published pages" do
      get "/api/v1/sites/#{site.slug}", headers: auth_headers

      expect(response).to have_http_status(:ok)
      payload = JSON.parse(response.body)
      expect(payload["slug"]).to eq("docs")
      expect(payload["resolved_locale"]).to eq("en")
      expect(payload["pages"].map { |page| page["slug"] }).to include("home", "about")
      expect(payload["pages"].find { |page| page["slug"] == "history" }["path"]).to eq("about/history")
      expect(payload["logo_url"]).to eq(payload["favicon_url"])
      expect(payload["favicon_url"]).to include("/rails/active_storage/blobs/")
    end

    it "uses the configured api_site_serializer_class" do
      serializer = Class.new do
        def initialize(site:, requested_locale:, main_app: nil)
          @main_app = main_app
          @site = site
          @requested_locale = requested_locale
        end

        def as_json(include_pages: true)
          {
            slug: @site.slug,
            requested_locale: @requested_locale,
            include_pages: include_pages
          }
        end
      end
      stub_const("CustomSiteSerializer", serializer)
      Cms.config.api_site_serializer_class = "CustomSiteSerializer"

      get "/api/v1/sites/#{site.slug}", headers: auth_headers

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to include(
        "slug" => "docs",
        "include_pages" => true
      )
    end
  end
end
