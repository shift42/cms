# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Cms admin pages", type: :request do
  include Cms::Engine.routes.url_helpers

  let(:site) { create(:cms_site, name: "Docs", slug: "docs", published: true) }
  let!(:page) do
    create(:cms_page, :published, site: site, slug: "about", template_key: "landing").tap do |record|
      create(:cms_page_translation, page: record, locale: "en", title: "About")
      create(:cms_section, site: site, kind: "rich_text").tap do |section|
        create(:cms_section_translation,
               section: section,
               locale: "en",
               title: "About intro",
               content: "About content")
        create(:cms_page_section, page: record, section: section, position: 0)
      end
    end
  end

  let(:logo_upload) do
    Rack::Test::UploadedFile.new(
      Rails.root.join("public/icon.png"),
      "image/png"
    )
  end

  around do |example|
    previous_resolver = Cms.config.current_site_resolver
    Cms.config.current_site_resolver = ->(_controller) { site }
    example.run
    Cms.config.current_site_resolver = previous_resolver
  end

  describe "GET /admin/pages/:id/preview" do
    before do
      site.logo.attach(logo_upload)
    end

    it "renders the public page template with the public layout" do
      get preview_admin_page_path(page)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("<html>")
      expect(response.body).to include("About")
      expect(response.body).to include("rel=\"icon\"")
      expect(response.body).to include("cms-page-template--landing")
    end
  end

  describe "GET /admin/pages" do
    context "when the site has no pages" do
      let!(:page) { nil }

      it "renders a helpful empty state" do
        get admin_pages_path

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Pages are listed in site order.")
        expect(response.body).to include("No pages yet. Create your first page to start building the site.")
      end
    end

    context "when no site exists yet" do
      let!(:page) { nil }

      it "redirects to the site bootstrap form" do
        previous_resolver = Cms.config.current_site_resolver
        Cms.config.current_site_resolver = ->(*) {}

        get admin_pages_path

        expect(response).to redirect_to(new_admin_site_path)
      ensure
        Cms.config.current_site_resolver = previous_resolver
      end
    end
  end
end
