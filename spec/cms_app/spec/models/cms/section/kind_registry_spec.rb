# frozen_string_literal: true

require "rails_helper"

RSpec.describe Cms::Section::KindRegistry do
  around do |example|
    described_class.reset!
    example.run
    described_class.reset!
    # Re-register built-ins so other specs are unaffected
    block_classes = {
      "rich_text" => Cms::Section::Blocks::RichTextBlock,
      "image" => Cms::Section::Blocks::ImageBlock,
      "hero" => Cms::Section::Blocks::HeroBlock,
      "cta" => Cms::Section::Blocks::CallToActionBlock
    }
    Cms::Section::KindRegistry::BUILT_IN_KINDS.each do |k|
      described_class.register(k, block_class: block_classes[k])
    end
  end

  describe ".register" do
    it "registers a kind with the default partial path" do
      described_class.register("cta")
      expect(described_class.partial_for("cta")).to eq("cms/sections/kinds/cta")
    end

    it "registers a kind with a custom partial path" do
      described_class.register("cta", partial: "my_app/sections/cta")
      expect(described_class.partial_for("cta")).to eq("my_app/sections/cta")
    end

    it "accepts symbol kind" do
      described_class.register(:banner)
      expect(described_class.partial_for("banner")).to eq("cms/sections/kinds/banner")
    end

    it "stores an optional block_class" do
      described_class.register("hero", block_class: Cms::Section::Blocks::HeroBlock)
      expect(described_class.block_class_for("hero")).to eq(Cms::Section::Blocks::HeroBlock)
    end
  end

  describe ".partial_for" do
    it "returns the partial path for a registered kind" do
      described_class.register("rich_text")
      expect(described_class.partial_for("rich_text")).to eq("cms/sections/kinds/rich_text")
    end

    it "raises UnknownKindError for an unregistered kind" do
      expect { described_class.partial_for("unknown") }
        .to raise_error(Cms::Section::KindRegistry::UnknownKindError, /unknown/)
    end

    it "includes registered kinds in the error message" do
      described_class.register("hero")
      expect { described_class.partial_for("unknown") }
        .to raise_error(Cms::Section::KindRegistry::UnknownKindError, /hero/)
    end
  end

  describe ".block_class_for" do
    it "returns nil when no block_class was registered" do
      described_class.register("plain")
      expect(described_class.block_class_for("plain")).to be_nil
    end

    it "raises UnknownKindError for an unregistered kind" do
      expect { described_class.block_class_for("unknown") }
        .to raise_error(Cms::Section::KindRegistry::UnknownKindError)
    end
  end

  describe ".registered_kinds" do
    it "returns all registered kind strings" do
      described_class.register("rich_text")
      described_class.register("image")
      expect(described_class.registered_kinds).to contain_exactly("rich_text", "image")
    end

    it "returns an empty array when nothing is registered" do
      expect(described_class.registered_kinds).to eq([])
    end
  end

  describe ".registered?" do
    it "returns true for a registered kind" do
      described_class.register("hero")
      expect(described_class.registered?("hero")).to be true
    end

    it "returns false for an unregistered kind" do
      expect(described_class.registered?("unknown")).to be false
    end
  end

  describe "built-in kinds (registered via engine initializer)" do
    before do
      block_classes = {
        "rich_text" => Cms::Section::Blocks::RichTextBlock,
        "image" => Cms::Section::Blocks::ImageBlock,
        "hero" => Cms::Section::Blocks::HeroBlock,
        "cta" => Cms::Section::Blocks::CallToActionBlock
      }
      Cms::Section::KindRegistry::BUILT_IN_KINDS.each do |k|
        described_class.register(k, block_class: block_classes[k])
      end
    end

    it "registers rich_text" do
      expect(described_class.registered?("rich_text")).to be true
    end

    it "registers image" do
      expect(described_class.registered?("image")).to be true
    end

    it "registers hero" do
      expect(described_class.registered?("hero")).to be true
    end

    it "registers cta" do
      expect(described_class.registered?("cta")).to be true
    end

    it "associates block classes with built-in kinds" do
      expect(described_class.block_class_for("cta")).to eq(Cms::Section::Blocks::CallToActionBlock)
    end
  end
end
