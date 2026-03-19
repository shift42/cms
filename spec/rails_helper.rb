# frozen_string_literal: true

require "spec_helper"
ENV["RAILS_ENV"] ||= "test"
ENGINE_ROOT = File.expand_path("..", __dir__)
require_relative "cms_app/config/environment"

abort("The Rails environment is running in production mode!") if Rails.env.production?

Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

require "rspec/rails"
require "factory_bot_rails"

begin
  ActiveRecord::Migrator.migrations_paths = [File.join(ENGINE_ROOT, "spec/cms_app/db/migrate")]
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end

RSpec.configure do |config|
  config.fixture_paths = [Rails.root.join("spec/fixtures")]
  config.use_transactional_fixtures = true
  config.filter_rails_from_backtrace!

  FactoryBot.definition_file_paths = [File.join(ENGINE_ROOT, "spec/cms_app/spec/factories")]
  FactoryBot.factories.clear
  FactoryBot.find_definitions

  config.include FactoryBot::Syntax::Methods

  config.include ActiveSupport::Testing::TimeHelpers
end
