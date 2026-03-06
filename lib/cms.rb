# frozen_string_literal: true

require "discard"
require "cms/version"
require "cms/engine"

module Cms
  class Configuration
    attr_accessor :parent_controller,
                  :admin_parent_controller,
                  :current_site_resolver,
                  :form_submission_email,
                  :mailer_from,
                  :image_renditions,
                  :page_templates,
                  :page_resolver_class,
                  :api_site_serializer_class,
                  :api_page_serializer_class,
                  :admin_layout,
                  :public_layout,
                  :authorize_admin,
                  :auto_destroy_orphaned_sections

    def initialize
      @parent_controller = "ApplicationController"
      @admin_parent_controller = nil
      @admin_layout = "cms/application"
      @public_layout = "cms/public"
      @image_renditions = {}
      @page_templates = []
      @page_resolver_class = "Cms::PageResolver"
      @api_site_serializer_class = "Cms::Api::SiteSerializer"
      @api_page_serializer_class = "Cms::Api::PageSerializer"
      @mailer_from = nil
      @authorize_admin = nil
      @auto_destroy_orphaned_sections = false
    end
  end

  class << self
    def config
      @config ||= Configuration.new
    end

    def setup
      yield config
    end

    def parent_controller
      config.parent_controller
    end

    def parent_controller=(val)
      config.parent_controller = val
    end

    def page_resolver_class
      constantize_config_value(config.page_resolver_class)
    end

    def api_site_serializer_class
      constantize_config_value(config.api_site_serializer_class)
    end

    def api_page_serializer_class
      constantize_config_value(config.api_page_serializer_class)
    end

    private

    def constantize_config_value(value)
      value.is_a?(String) ? value.constantize : value
    end
  end
end
