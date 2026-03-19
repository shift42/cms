# frozen_string_literal: true

require "rails/generators/base"

module Cms
  module Generators
    class ViewsGenerator < Rails::Generators::Base
      source_root Cms::Engine.root.join("app/views")
      desc "Copies CMS views to your application."

      argument :scope,
               required: false,
               default: nil,
               desc: "Select a view scope (admin, public, mailer, all)"

      class_option :views,
                   aliases: "-v",
                   type: :array,
                   desc: "Select specific view scopes to generate (admin, public, mailer)"

      VIEW_GROUPS = {
        "admin" => [
          "cms/admin"
        ],
        "public" => [
          "cms/sections",
          "cms/public",
          "layouts/cms"
        ],
        "mailer" => [
          "cms/form_submission_mailer"
        ],
        "all" => [
          "cms",
          "layouts/cms"
        ]
      }.freeze

      def copy_views
        selected_groups.each do |group|
          copy_group(group)
        end
      end

      private

      def selected_groups
        groups =
          if options[:views].present?
            options[:views]
          elsif scope.present?
            [scope]
          else
            ["all"]
          end

        normalized = groups.map { |entry| entry.to_s.downcase }.uniq
        invalid = normalized - VIEW_GROUPS.keys
        return normalized if invalid.empty?

        raise Thor::Error, "Unknown view scope(s): #{invalid.join(', ')}. " \
                           "Valid scopes: #{VIEW_GROUPS.keys.join(', ')}"
      end

      def copy_group(group)
        VIEW_GROUPS.fetch(group).each do |relative_path|
          source = Cms::Engine.root.join("app/views", relative_path)
          target = File.join("app/views", relative_path)

          if source.directory?
            directory relative_path, target
          else
            copy_file relative_path, target
          end
        end
      end
    end
  end
end
