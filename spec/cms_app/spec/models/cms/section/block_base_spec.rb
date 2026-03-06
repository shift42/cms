# frozen_string_literal: true

require "rails_helper"

RSpec.describe Cms::Section::BlockBase do
  describe ".settings_schema" do
    it "returns an empty array by default" do
      block = Class.new(described_class)
      expect(block.settings_schema).to eq([])
    end

    it "is independent per subclass" do
      block_a = Class.new(described_class) { settings_field :title, type: :string }
      block_b = Class.new(described_class) { settings_field :url, type: :url }

      expect(block_a.settings_schema.map { |f| f[:name] }).to eq(["title"])
      expect(block_b.settings_schema.map { |f| f[:name] }).to eq(["url"])
    end
  end

  describe ".settings_field" do
    let(:block) do
      Class.new(described_class) do
        settings_field :button_text, type: :string, required: true
        settings_field :alignment, type: :select, default: "center", options: %w[left center right]
      end
    end

    it "adds field definitions to the schema" do
      expect(block.settings_schema.length).to eq(2)
    end

    it "stores the field name as a string" do
      expect(block.settings_schema.first[:name]).to eq("button_text")
    end

    it "stores type, required, default, options" do
      align = block.settings_schema.last
      expect(align[:type]).to eq(:select)
      expect(align[:default]).to eq("center")
      expect(align[:options]).to eq(%w[left center right])
    end

    it "omits nil optional keys (compact)" do
      field = block.settings_schema.first
      expect(field).not_to have_key(:options)
      expect(field).not_to have_key(:default)
    end
  end

  describe ".kind" do
    it "raises NotImplementedError on the base class" do
      expect { described_class.kind }.to raise_error(NotImplementedError)
    end
  end
end
