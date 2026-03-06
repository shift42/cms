# frozen_string_literal: true

require "rails_helper"

RSpec.describe Cms::Webhook, type: :model do
  describe "validations" do
    it "is valid with supported events" do
      webhook = build(:cms_webhook)

      expect(webhook).to be_valid
    end

    it "rejects unsupported events" do
      webhook = build(:cms_webhook, events: ["page.published", "page.deleted"])

      expect(webhook).not_to be_valid
      expect(webhook.errors[:events]).to include("contains unsupported values: page.deleted")
    end

    it "normalizes duplicate and blank events" do
      webhook = build(:cms_webhook, events: ["page.unpublished", "", "page.unpublished", :"page.published"])

      webhook.validate

      expect(webhook.events).to eq(%w[page.unpublished page.published])
    end
  end
end
