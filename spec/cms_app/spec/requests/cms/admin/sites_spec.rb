# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Cms admin sites", type: :request do
  include Cms::Engine.routes.url_helpers

  around do |example|
    previous_resolver = Cms.config.current_site_resolver
    Cms.config.current_site_resolver = current_site_resolver
    example.run
    Cms.config.current_site_resolver = previous_resolver
  end

  let(:current_site_resolver) { ->(_controller) { site } }

  describe "GET /admin/site/new" do
    context "when no site exists yet" do
      let(:current_site_resolver) { ->(*) {} }

      it "renders the bootstrap form" do
        get new_admin_site_path

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Create Website")
        expect(response.body).to include("Create the first CMS site")
      end
    end

    context "when a site already exists" do
      let!(:site) { create(:cms_site, name: "Docs", slug: "docs", published: true) }

      it "redirects to edit" do
        get new_admin_site_path

        expect(response).to redirect_to(edit_admin_site_path)
      end
    end
  end

  describe "POST /admin/site" do
    let(:current_site_resolver) { ->(*) {} }

    it "creates the first site" do
      post admin_site_path, params: {
        site: { name: "Docs", slug: "docs", default_locale: "en", published: true }
      }

      expect(response).to redirect_to(admin_site_path)
      expect(Cms::Site.count).to eq(1)
      expect(Cms::Site.last.slug).to eq("docs")
    end
  end

  describe "GET /admin/site/edit" do
    let!(:site) { create(:cms_site, name: "Docs", slug: "docs", published: true) }
    let!(:other_site) { create(:cms_site, name: "Blog", slug: "blog", published: true) }

    it "does not expose a separate favicon attachment field" do
      get edit_admin_site_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Used for both the site logo and favicon.")
      expect(response.body).not_to include("site[favicon]")
      expect(response.body).not_to include("Remove favicon")
    end

    it "uses the configured current_site_resolver when present" do
      Cms.config.current_site_resolver = ->(_controller) { other_site }

      get edit_admin_site_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("value=\"Blog\"")
    end
  end
end
