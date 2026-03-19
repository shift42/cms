# frozen_string_literal: true

require "rails/generators"
require "rails/generators/active_record"

module Cms
  module Generators
    class InstallGenerator < Rails::Generators::Base
      include Rails::Generators::Migration

      source_root File.expand_path("templates", __dir__)

      def create_migrations
        migration_template "create_cms_tables.rb", "db/migrate/create_cms_tables.rb"
      end

      def copy_initializer
        template "initializer.rb", "config/initializers/cms.rb"
      end

      def self.next_migration_number(dirname)
        ActiveRecord::Generators::Base.next_migration_number(dirname)
      end
    end
  end
end
