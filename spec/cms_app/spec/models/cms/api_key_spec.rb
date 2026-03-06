# frozen_string_literal: true

require "rails_helper"

RSpec.describe Cms::ApiKey, type: :model do
  let!(:site) { create(:cms_site) }

  describe "token generation" do
    it "generates a token before create" do
      key = create(:cms_api_key, site: site)
      expect(key.token).to be_present
      expect(key.token.length).to eq(64)
    end

    it "generates unique tokens" do
      k1 = create(:cms_api_key, site: site)
      k2 = create(:cms_api_key, site: site)
      expect(k1.token).not_to eq(k2.token)
    end
  end

  describe "scopes" do
    let!(:active_key)   { create(:cms_api_key, site: site, active: true) }
    let!(:inactive_key) { create(:cms_api_key, site: site, active: false) }

    it "active returns only active keys" do
      expect(Cms::ApiKey.active).to include(active_key)
      expect(Cms::ApiKey.active).not_to include(inactive_key)
    end
  end

  describe "#touch_last_used!" do
    it "updates last_used_at" do
      key = create(:cms_api_key, site: site)
      expect { key.touch_last_used! }.to(change { key.reload.last_used_at })
    end
  end

  describe "validations" do
    it "requires a name" do
      key = build(:cms_api_key, site: site, name: nil)
      expect(key).not_to be_valid
    end
  end
end
