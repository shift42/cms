# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Built-in block classes" do
  describe Cms::Section::Blocks::RichTextBlock do
    it "has kind 'rich_text'" do
      expect(described_class.kind).to eq("rich_text")
    end

    it "has no settings fields" do
      expect(described_class.settings_schema).to be_empty
    end
  end

  describe Cms::Section::Blocks::ImageBlock do
    it "has kind 'image'" do
      expect(described_class.kind).to eq("image")
    end

    it "declares only the image associations field" do
      names = described_class.settings_schema.map { |f| f[:name] }
      expect(names).to eq(%w[image_ids])
    end
  end

  describe Cms::Section::Blocks::HeroBlock do
    it "has kind 'hero'" do
      expect(described_class.kind).to eq("hero")
    end

    it "has a background_color field with default" do
      field = described_class.settings_schema.find { |f| f[:name] == "background_color" }
      expect(field[:default]).to eq("#ffffff")
    end
  end

  describe Cms::Section::Blocks::CallToActionBlock do
    it "has kind 'cta'" do
      expect(described_class.kind).to eq("cta")
    end

    it "marks button_text and button_url as required" do
      required = described_class.settings_schema.select { |f| f[:required] }.map { |f| f[:name] }
      expect(required).to contain_exactly("button_text", "button_url")
    end

    it "has alignment select with options" do
      field = described_class.settings_schema.find { |f| f[:name] == "alignment" }
      expect(field[:options]).to eq(%w[left center right])
    end
  end
end
