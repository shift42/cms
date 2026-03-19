# frozen_string_literal: true

require "action_text/engine"

module Cms
  class Engine < ::Rails::Engine
    isolate_namespace Cms

    initializer "cms.assets.precompile" do |app|
      app.config.assets.precompile += %w[cms/application.css cms/application.js]
    end

    initializer "cms.importmap", before: "importmap" do |app|
      if app.config.respond_to?(:importmap)
        app.config.importmap.paths << Engine.root.join("config/importmap.rb")
        app.config.importmap.cache_sweepers << Engine.root.join("app/javascript")
      end
    end

    config.after_initialize do
      if Rails.env.production? && Cms.config.admin_parent_controller.blank?
        raise "Cms: admin_parent_controller must be configured in production. " \
              "Set it in your Cms.setup block, e.g.: config.admin_parent_controller = \"AdminController\""
      end
    end

    config.to_prepare do
      # Section block classes
      section_block_classes = {
        "rich_text" => Cms::Section::Blocks::RichTextBlock,
        "image" => Cms::Section::Blocks::ImageBlock,
        "hero" => Cms::Section::Blocks::HeroBlock,
        "cta" => Cms::Section::Blocks::CallToActionBlock
      }

      Cms::Section::KindRegistry::BUILT_IN_KINDS.each do |kind|
        Cms::Section::KindRegistry.register(kind, block_class: section_block_classes[kind])
      end

      Array(Cms.config.page_templates).each do |key|
        Cms::Page::TemplateRegistry.register(key)
      end
    end
  end
end
