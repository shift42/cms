# frozen_string_literal: true

module Cms
  class FormSubmission < ApplicationRecord
    self.table_name = "cms_form_submissions"

    belongs_to :page, class_name: "Cms::Page", inverse_of: :form_submissions

    validates :data, presence: true
    validate :contains_response_data
    validate :required_fields_present

    scope :recent, -> { order(created_at: :desc) }

    def self.to_csv(submissions, fields)
      require "csv"

      CSV.generate(headers: true) do |csv|
        csv << ([I18n.t("cms.admin.form_submissions.index.submitted_at")] + fields.map(&:label))
        submissions.each do |sub|
          csv << ([I18n.l(sub.created_at, format: :cms_csv_datetime)] + fields.map { |f| sub.data[f.field_name] })
        end
      end
    end

    private

    def contains_response_data
      values = data.to_h.values.reject { |value| value.to_s.in?(%w[0]) }
      errors.add(:base, I18n.t("cms.errors.form_submission.blank")) if values.all?(&:blank?)
    end

    def required_fields_present
      page.form_fields.ordered.select(&:required?).each do |field|
        value = data.to_h[field.field_name]
        next unless value.to_s.blank? || value.to_s == "0"

        errors.add(field.field_name.to_sym, I18n.t("cms.errors.form_submission.required", label: field.label))
      end
    end
  end
end
