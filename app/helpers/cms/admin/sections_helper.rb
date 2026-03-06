# frozen_string_literal: true

module Cms
  module Admin
    module SectionsHelper
      # Renders a form field for a block settings field definition.
      #
      # @param form [ActionView::Helpers::FormBuilder]
      # @param field [Hash] field definition from BlockBase.settings_schema
      def render_settings_field(form, field, site: nil)
        name = field[:name]

        content_tag(:div, class: "cms-form__field") do
          concat form.label("settings_#{name}", cms_section_setting_label(name), class: "cms-form__label")
          concat settings_input(form, field, site: site)
          if field[:type] == :image
            concat image_library_actions
            concat image_library_hint(site) if site&.images&.none?
          end
        end
      end

      def cms_section_image_options(site)
        return [] unless site

        site.images.ordered.map { |image| [image.display_title, image.id] }
      end

      private

      def settings_input(form, field, site:)
        name = field[:name]

        case field[:type]
        when :url
          form.url_field "settings[#{name}]", input_options(form, name)
        when :color
          form.color_field "settings[#{name}]", input_options(form, name, default: field[:default])
        when :boolean
          form.check_box "settings[#{name}]", { class: "cms-checkbox" }, "true", "false"
        when :select
          form.select "settings[#{name}]",
                      select_options(field),
                      { selected: form.object.settings[name] || field[:default] },
                      class: "cms-input"
        when :image
          form.select "settings[#{name}]",
                      cms_section_image_options(site),
                      {
                        include_blank: t("cms.admin.sections.form.select_image"),
                        selected: form.object.settings[name]
                      },
                      class: "cms-input"
        else
          form.text_field "settings[#{name}]", input_options(form, name)
        end
      end

      def input_options(form, name, default: nil)
        { class: "cms-input", value: form.object.settings[name] || default }
      end

      def select_options(field)
        field[:options].map { |option| [cms_section_setting_option_label(field[:name], option), option] }
      end

      def image_library_hint(site)
        return "".html_safe unless site&.images&.none?

        content_tag(:p, t("cms.admin.sections.form.image_library_empty"), class: "cms-form__hint")
      end

      def image_library_actions
        content_tag(:p, class: "cms-form__hint") do
          safe_join(
            [
              link_to(t("cms.admin.sections.form.manage_images"), admin_images_path),
              " ",
              link_to(t("cms.admin.sections.form.upload_image"), new_admin_image_path)
            ]
          )
        end
      end
    end
  end
end
