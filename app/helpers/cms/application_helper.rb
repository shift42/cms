# frozen_string_literal: true

module Cms
  module ApplicationHelper
    def cms_attachment_path(attachment)
      return unless attachment.attached?

      main_app.rails_blob_path(attachment, only_path: true)
    end

    def cms_yes_no(value)
      t(value ? "cms.shared.yes" : "cms.shared.no")
    end

    def cms_date(value)
      l(value.to_date, format: :cms_date)
    end

    def cms_datetime(value)
      l(value, format: :cms_datetime)
    end

    def cms_page_template_label(key)
      t("cms.page_templates.#{key}")
    end

    def cms_page_status_label(key)
      t("cms.page_statuses.#{key}")
    end

    def cms_form_field_kind_label(key)
      t("cms.form_field_kinds.#{key}")
    end

    def cms_section_kind_label(key)
      t("cms.section_kinds.#{key}")
    end

    def cms_webhook_event_label(key)
      t("cms.webhook_events.#{key.tr('.', '_')}")
    end

    def cms_section_setting_label(name)
      t("cms.section_settings.labels.#{name}")
    end

    def cms_section_setting_option_label(name, option)
      t("cms.section_settings.options.#{name}.#{option}")
    end
  end
end
