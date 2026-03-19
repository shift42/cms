# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Cms::Admin::Sections", type: :request do
  include Cms::Engine.routes.url_helpers

  let!(:site) { create(:cms_site, name: "Test", slug: "test", published: true) }
  let!(:page) do
    create(:cms_page, :published, site: site, slug: "home").tap do |p|
      create(:cms_page_translation, page: p, locale: "en", title: "Home")
    end
  end

  around do |example|
    previous_resolver = Cms.config.current_site_resolver
    Cms.config.current_site_resolver = ->(_controller) { site }
    example.run
    Cms.config.current_site_resolver = previous_resolver
  end

  describe "GET /admin/pages/:page_id/sections/new" do
    it "returns 200 with the default kind" do
      get new_admin_page_section_path(page)
      expect(response).to have_http_status(:ok)
    end

    it "returns 200 with a specified kind" do
      get new_admin_page_section_path(page, kind: "cta")
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(I18n.t("cms.section_kinds.cta"))
    end
  end

  describe "GET /admin/sections" do
    let!(:section) do
      create(:cms_section, :global, site: site, kind: "cta",
                                    button_url: "https://example.com", alignment: "center").tap do |record|
        create(:cms_section_translation,
               section: record,
               locale: "en",
               title: "Shared CTA",
               subtitle: "Book",
               content: "Shared CTA body")
        create(:cms_page_section, page: page, section: record)
      end
    end

    it "renders the reusable section library" do
      get admin_sections_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Sections")
      expect(response.body).to include("Shared CTA")
      expect(response.body).to include("Home")
    end
  end

  describe "POST /admin/sections" do
    let!(:image) { create(:cms_image, site: site, title: "Hero asset") }

    it "creates a reusable image section without attaching it to a page" do
      initial_page_section_count = Cms::PageSection.count

      expect do
        post admin_sections_path, params: {
          section: {
            kind: "image",
            enabled: true,
            image_ids: [image.id.to_s]
          }
        }
      end.to change(Cms::Section, :count).by(1)

      expect(response).to redirect_to(admin_sections_path(locale: "en"))
      expect(Cms::PageSection.count).to eq(initial_page_section_count)
      expect(Cms::Section.last.images.pluck(:id)).to eq([image.id])
    end
  end

  describe "POST /admin/pages/:page_id/sections" do
    context "with valid rich_text params" do
      let(:valid_params) do
        {
          section: {
            kind: "rich_text",
            enabled: true,
            translations_attributes: [{ locale: "en", title: "Intro", content: "Intro body" }]
          }
        }
      end

      it "creates a section and redirects to the page" do
        initial_section_count = Cms::Section.count
        initial_page_section_count = Cms::PageSection.count

        expect do
          post admin_page_sections_path(page), params: valid_params
        end.to change { Cms::Section.count - initial_section_count }.by(1)

        expect(Cms::PageSection.count - initial_page_section_count).to eq(1)
        expect(response).to redirect_to(admin_page_path(page, locale: "en"))
      end

      it "creates a section translation" do
        post admin_page_sections_path(page), params: valid_params
        expect(page.reload.sections.last.translations.where(locale: "en").count).to eq(1)
      end
    end

    context "with a cta section requiring settings" do
      it "creates a section without required settings validation at create time" do
        params = {
          section: {
            kind: "cta",
            enabled: true,
            button_url: "https://example.com",
            alignment: "center",
            translations_attributes: [{ locale: "en", title: "CTA", subtitle: "Click me", content: "CTA body" }]
          }
        }

        expect do
          post admin_page_sections_path(page), params: params
        end.to change(Cms::Section, :count).by(1)
                                           .and change(Cms::PageSection, :count).by(1)
      end
    end

    context "with invalid params (missing kind)" do
      it "renders new with 422" do
        post admin_page_sections_path(page), params: { section: { kind: "" } }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "GET /admin/pages/:page_id/sections/:id/edit" do
    let!(:section) do
      create(:cms_section, site: site, kind: "rich_text").tap do |s|
        create(:cms_page_section, page: page, section: s)
        create(:cms_section_translation, section: s, locale: "en", title: "Intro block", content: "Intro body")
      end
    end

    it "returns 200" do
      get edit_admin_page_section_path(page, section)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Intro block")
    end
  end

  describe "PATCH /admin/pages/:page_id/sections/:id" do
    let!(:section) do
      create(:cms_section, site: site, kind: "rich_text").tap do |s|
        create(:cms_page_section, page: page, section: s)
        create(:cms_section_translation, section: s, locale: "en", title: "Old title", content: "Old body")
      end
    end

    it "updates the section translation and redirects" do
      patch admin_page_section_path(page, section), params: {
        section: {
          translations_attributes: [
            { id: section.translations.first.id, locale: "en", title: "New title", content: "Old body" }
          ]
        }
      }

      expect(response).to redirect_to(admin_page_path(page, locale: "en"))
      expect(section.translations.first.reload.title).to eq("New title")
    end
  end

  describe "PATCH /admin/sections/:id" do
    let!(:section) do
      create(:cms_section, site: site, kind: "rich_text").tap do |record|
        create(:cms_section_translation, section: record, locale: "en", title: "Old shared title", content: "Old body")
      end
    end

    it "updates a reusable section from the library" do
      patch admin_section_path(section), params: {
        section: {
          translations_attributes: [
            { id: section.translations.first.id, locale: "en", title: "New shared title", content: "Old body" }
          ]
        }
      }

      expect(response).to redirect_to(admin_sections_path(locale: "en"))
      expect(section.translations.first.reload.title).to eq("New shared title")
    end
  end

  describe "DELETE /admin/pages/:page_id/sections/:id" do
    let!(:section) do
      create(:cms_section, site: site, kind: "rich_text").tap do |s|
        create(:cms_page_section, page: page, section: s)
      end
    end

    it "removes the page placement and preserves the section" do
      expect do
        delete admin_page_section_path(page, section)
      end.to change(Cms::PageSection, :count).by(-1)

      expect(Cms::Section.exists?(section.id)).to be true
      expect(response).to redirect_to(admin_page_path(page))
    end
  end

  describe "DELETE /admin/sections/:id" do
    let!(:section) do
      create(:cms_section, site: site, kind: "rich_text").tap do |record|
        create(:cms_page_section, page: page, section: record)
      end
    end

    it "soft-deletes the reusable section and preserves its page attachments" do
      expect do
        delete admin_section_path(section)
      end.to change { Cms::Section.kept.count }.by(-1)

      expect(response).to redirect_to(admin_sections_path)
      expect(section.reload.discarded?).to be true
      expect(section.page_sections.count).to eq(1)
    end
  end

  describe "PATCH /admin/pages/:page_id/sections/sort" do
    let!(:section_a) { create(:cms_section, site: site, kind: "rich_text") }
    let!(:section_b) { create(:cms_section, site: site, kind: "hero") }
    let!(:page_section_a) { create(:cms_page_section, page: page, section: section_a, position: 0) }
    let!(:page_section_b) { create(:cms_page_section, page: page, section: section_b, position: 1) }

    it "updates positions and returns 200" do
      patch admin_page_sort_sections_path(page), params: {
        page_section_ids: [page_section_b.id, page_section_a.id]
      }

      expect(response).to have_http_status(:ok)
      expect(page_section_b.reload.position).to eq(0)
      expect(page_section_a.reload.position).to eq(1)
    end
  end

  describe "POST /admin/pages/:page_id/sections/attach" do
    let!(:section) do
      create(:cms_section, :global, site: site, kind: "cta",
                                    button_url: "https://example.com/book", alignment: "center").tap do |record|
        create(:cms_section_translation,
               section: record,
               locale: "en",
               title: "Shared CTA",
               subtitle: "Book a call",
               content: "CTA body")
      end
    end

    it "attaches an existing reusable section to the page" do
      expect do
        post admin_page_attach_section_path(page), params: { section_id: section.id }
      end.to change(Cms::PageSection, :count).by(1)

      expect(response).to redirect_to(admin_page_path(page))
      expect(page.reload.sections).to include(section)
    end
  end
end
