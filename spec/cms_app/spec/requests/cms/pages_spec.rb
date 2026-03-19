# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Cms pages", type: :request do
  include Cms::Engine.routes.url_helpers

  around do |example|
    previous_resolver = Cms.config.current_site_resolver
    previous_page_resolver_class = Cms.config.page_resolver_class

    example.run
  ensure
    Cms.config.current_site_resolver = previous_resolver
    Cms.config.page_resolver_class = previous_page_resolver_class
  end

  let!(:site) do
    create(:cms_site, name: "Docs", slug: "docs", published: true)
  end

  let!(:home_page) do
    create(:cms_page, :published, site: site, slug: "home", home: true).tap do |page|
      create(:cms_page_translation, page: page, locale: "en", title: "Home")
      create(:cms_section, site: site, kind: "rich_text").tap do |section|
        create(:cms_section_translation,
               section: section,
               locale: "en",
               title: "Home intro",
               content: "Welcome to docs")
        create(:cms_page_section, page: page, section: section, position: 0)
      end
    end
  end

  let!(:about_page) do
    create(:cms_page, :published, site: site, slug: "about", template_key: "landing").tap do |page|
      create(:cms_page_translation, page: page, locale: "en", title: "About")
      create(:cms_section, site: site, kind: "rich_text").tap do |section|
        create(:cms_section_translation,
               section: section,
               locale: "en",
               title: "About intro",
               content: "About content")
        create(:cms_page_section, page: page, section: section, position: 0)
      end
    end
  end

  let!(:history_page) do
    create(:cms_page, :published, site: site, slug: "history", parent: about_page).tap do |page|
      create(:cms_page_translation, page: page, locale: "en", title: "History")
      create(:cms_section, site: site, kind: "rich_text").tap do |section|
        create(:cms_section_translation,
               section: section,
               locale: "en",
               title: "History intro",
               content: "Our history")
        create(:cms_page_section, page: page, section: section, position: 0)
      end
    end
  end

  let!(:contact_field) do
    create(:cms_form_field, page: about_page, kind: "email", label: "Email", field_name: "email", required: true)
  end

  let!(:shared_image) do
    create(:cms_image, site: site, title: "About photo").tap do |image|
      image.image_translations.find_by!(locale: "en").update!(caption: "About team")
    end
  end

  let!(:image_section) do
    create(:cms_section, site: site, kind: "image").tap do |section|
      create(:cms_section_image, section: section, image: shared_image, position: 0)
      create(:cms_page_section, page: about_page, section: section)
    end
  end

  let(:logo_upload) do
    Rack::Test::UploadedFile.new(
      Rails.root.join("public/icon.png"),
      "image/png"
    )
  end

  describe "GET /sites/:site_slug" do
    before do
      site.logo.attach(logo_upload)
    end

    it "renders the site home page" do
      get site_path(site.slug)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Home")
      expect(response.body).to include("Welcome to docs")
    end

    it "uses the logo attachment as the favicon" do
      get site_page_path(site.slug, about_page.slug)

      expect(response.body).to include("rel=\"icon\"")
      expect(response.body).to include("/rails/active_storage/blobs/")
      expect(response.body).to include("Contact")
    end

    it "renders nested pages with ancestor-based paths" do
      get site_page_path(site.slug, "about/history")

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("History")
      expect(response.body).to include("Our history")
    end

    it "renders image sections from the CMS media library" do
      image_section

      get site_page_path(site.slug, about_page.slug)

      expect(response.body).to include("About team")
      expect(response.body).to include("/rails/active_storage/blobs/")
    end

    it "renders the page template selected by template_key" do
      get site_page_path(site.slug, about_page.slug)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("cms-page-template--landing")
    end
  end

  describe "template fallback" do
    let!(:campaign_page) do
      Cms::Page::TemplateRegistry.register("campaign")

      create(:cms_page, :published, site: site, slug: "campaign", template_key: "campaign").tap do |page|
        create(:cms_page_translation, page: page, locale: "en", title: "Campaign")
      end
    end

    it "falls back to the default page template when a template partial is missing" do
      get site_page_path(site.slug, campaign_page.slug)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("cms-page-template--standard")
      expect(response.body).to include("Campaign")
    end
  end

  describe "GET /" do
    before do
      Cms.config.current_site_resolver = ->(_controller) { site }
    end

    it "renders the resolved current site without requiring a slug header" do
      get current_site_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Home")
    end
  end

  describe "configured page_resolver_class" do
    it "uses the configured resolver for public page rendering" do
      resolver = Class.new do
        def self.resolve(site:, slug:, locale:)
          raise "unexpected site" unless site.slug == "docs"
          raise "unexpected slug" unless slug == "about"
          raise "unexpected locale" unless locale == I18n.locale.to_s

          Cms::PageResolver::Result.new(page: Cms::Page.find_by!(slug: "about"), locale: "en")
        end
      end
      stub_const("PublicPageResolver", resolver)
      Cms.config.page_resolver_class = "PublicPageResolver"

      get site_page_path(site.slug, about_page.slug)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("About")
    end
  end

  describe "POST /pages/:page_id/form_submissions" do
    it "creates a site-scoped submission" do
      expect do
        post page_form_submissions_path(about_page, site_slug: site.slug),
             params: { submission: { email: "person@example.com" } }
      end.to change(Cms::FormSubmission, :count).by(1)

      expect(response).to redirect_to(site_page_path(site.slug, about_page.slug))
    end

    it "re-renders the page with validation errors when invalid" do
      post page_form_submissions_path(about_page, site_slug: site.slug),
           params: { submission: { email: "" } }

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("There was a problem with your submission")
      expect(response.body).to include("Email is required")
    end
  end
end
