# frozen_string_literal: true

require "rails_helper"

RSpec.describe Cms::Page, type: :model do
  let(:site) { create(:cms_site) }

  describe "nav_group" do
    it "allows custom navigation groups" do
      page = build(:cms_page, site: site, nav_group: "footer_secondary")

      expect(page).to be_valid
    end
  end
end
