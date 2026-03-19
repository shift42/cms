# frozen_string_literal: true

module Cms
  class FormField < ApplicationRecord
    self.table_name = "cms_form_fields"

    KINDS = %w[text email textarea select checkbox].freeze

    belongs_to :page, class_name: "Cms::Page", inverse_of: :form_fields

    validates :kind, presence: true, inclusion: { in: KINDS }
    validates :label, :field_name, presence: true
    validates :field_name, uniqueness: { scope: :page_id },
                           format: { with: /\A[a-z0-9_]+\z/,
                                     message: ->(*) { I18n.t("cms.errors.form_field.invalid_field_name") } }

    scope :ordered, -> { order(:position, :id) }

    def select?
      kind == "select"
    end

    def parsed_options
      Array(options)
    end
  end
end
