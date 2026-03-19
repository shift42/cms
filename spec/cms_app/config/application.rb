# frozen_string_literal: true

require_relative "boot"

require "rails"
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_text/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"

Bundler.require(*Rails.groups)

module CmsApp
  class Application < Rails::Application
    config.load_defaults Rails::VERSION::STRING.to_f
    config.eager_load = false
    config.action_controller.include_all_helpers = false
    config.hosts.clear
    config.generators.system_tests = nil
    config.active_support.deprecation = :stderr
    config.i18n.available_locales = %i[en el fr de ja]
    config.i18n.default_locale = :en
  end
end
