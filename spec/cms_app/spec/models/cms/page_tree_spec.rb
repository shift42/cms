# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Cms::Page tree", type: :model do
  let!(:site) { create(:cms_site) }

  let!(:root)  { create(:cms_page, site: site, slug: "root") }
  let!(:child) { create(:cms_page, site: site, slug: "child", parent: root) }
  let!(:grand) { create(:cms_page, site: site, slug: "grand", parent: child) }

  describe "#ancestors" do
    it "returns empty array for root page" do
      expect(root.ancestors).to eq([])
    end

    it "returns parent for child page" do
      expect(child.ancestors).to eq([root])
    end

    it "returns full chain for grandchild" do
      expect(grand.ancestors).to eq([root, child])
    end
  end

  describe "#depth" do
    it "returns 0 for root" do
      expect(root.depth).to eq(0)
    end

    it "returns 1 for child" do
      expect(child.depth).to eq(1)
    end

    it "returns 2 for grandchild" do
      expect(grand.depth).to eq(2)
    end
  end

  describe "#descendants" do
    it "returns all descendants of root" do
      expect(root.descendants).to include(child, grand)
    end

    it "returns direct child descendants" do
      expect(child.descendants).to eq([grand])
    end

    it "returns empty for leaf" do
      expect(grand.descendants).to eq([])
    end
  end

  describe "scope :root" do
    it "returns only pages without a parent" do
      roots = site.pages.root
      expect(roots).to include(root)
      expect(roots).not_to include(child, grand)
    end
  end

  describe "subpages dependent: :nullify" do
    it "nullifies parent_id on child when parent is destroyed" do
      root.destroy
      expect(child.reload.parent_id).to be_nil
    end
  end
end
