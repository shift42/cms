# frozen_string_literal: true

require "rails_helper"

RSpec.describe Cms::PageResolver do
  let(:site) { create(:cms_site, default_locale: "en") }

  let(:page_en) do
    create(:cms_page, :published, site: site, slug: "about").tap do |p|
      create(:cms_page_translation, page: p, locale: "en", title: "About EN")
    end
  end

  let(:page_multlingual) do
    create(:cms_page, :published, site: site, slug: "contact").tap do |p|
      create(:cms_page_translation, page: p, locale: "en", title: "Contact EN")
      create(:cms_page_translation, page: p, locale: "el", title: "Contact EL")
    end
  end

  let(:home_page) do
    create(:cms_page, :published, site: site, slug: "home", home: true).tap do |p|
      create(:cms_page_translation, page: p, locale: "en", title: "Home EN")
    end
  end

  let(:draft_page) do
    create(:cms_page, site: site, slug: "draft", status: "draft").tap do |p|
      create(:cms_page_translation, page: p, locale: "en", title: "Draft")
    end
  end

  let(:about_page) do
    create(:cms_page, :published, site: site, slug: "about").tap do |p|
      create(:cms_page_translation, page: p, locale: "en", title: "About")
    end
  end

  let(:history_page) do
    create(:cms_page, :published, site: site, slug: "history", parent: about_page).tap do |p|
      create(:cms_page_translation, page: p, locale: "en", title: "History")
    end
  end

  describe ".resolve" do
    context "slug lookup" do
      it "returns the page matching the slug" do
        page_en
        result = described_class.resolve(site: site, slug: "about", locale: "en")
        expect(result.page).to eq(page_en)
      end

      it "returns nil when no published page matches the slug" do
        result = described_class.resolve(site: site, slug: "nonexistent", locale: "en")
        expect(result).to be_nil
      end

      it "returns nil for a draft page" do
        draft_page
        result = described_class.resolve(site: site, slug: "draft", locale: "en")
        expect(result).to be_nil
      end

      it "resolves a nested path by ancestor chain" do
        history_page

        result = described_class.resolve(site: site, slug: "about/history", locale: "en")

        expect(result.page).to eq(history_page)
      end

      it "returns nil when the nested path does not match the ancestor chain" do
        history_page

        result = described_class.resolve(site: site, slug: "company/history", locale: "en")

        expect(result).to be_nil
      end
    end

    context "home page resolution" do
      it "returns the home page when slug is blank" do
        home_page
        result = described_class.resolve(site: site, slug: nil, locale: "en")
        expect(result.page).to eq(home_page)
      end

      it "returns the first published page when no home page is set" do
        page_en
        result = described_class.resolve(site: site, slug: "", locale: "en")
        expect(result.page).to eq(page_en)
      end
    end

    context "locale resolution" do
      it "returns the requested locale when a translation exists" do
        page_multlingual
        result = described_class.resolve(site: site, slug: "contact", locale: "el")
        expect(result.locale).to eq("el")
      end

      it "falls back to site.default_locale when the requested locale has no translation" do
        page_en
        result = described_class.resolve(site: site, slug: "about", locale: "fr")
        expect(result.locale).to eq("en")
      end

      it "falls back to I18n.default_locale when neither requested nor site default locale matches" do
        site_fr = create(:cms_site, default_locale: "fr")
        create(:cms_page, :published, site: site_fr, slug: "terms").tap do |p|
          create(:cms_page_translation, page: p, locale: "en", title: "Terms EN")
        end

        result = described_class.resolve(site: site_fr, slug: "terms", locale: "de")
        expect(result.locale).to eq(I18n.default_locale.to_s)
      end

      it "falls back to the first available translation when no fallback matches" do
        site_ja = create(:cms_site, default_locale: "ja")
        create(:cms_page, :published, site: site_ja, slug: "rare").tap do |p|
          create(:cms_page_translation, page: p, locale: "ja", title: "Japanese only")
        end

        result = described_class.resolve(site: site_ja, slug: "rare", locale: "de")
        expect(result.locale).to eq("ja")
      end
    end

    context "eager loading" do
      it "loads sections without raising" do
        create(:cms_page, :published, site: site, slug: "loaded").tap do |p|
          create(:cms_page_translation, page: p, locale: "en", title: "Loaded")
        end

        result = described_class.resolve(site: site, slug: "loaded", locale: "en")

        expect { result.page.sections.each(&:localised) }.not_to raise_error
      end
    end
  end
end
