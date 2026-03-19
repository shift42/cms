# frozen_string_literal: true

module Cms
  class Webhook < ApplicationRecord
    self.table_name = "cms_webhooks"

    EVENTS = %w[page.published page.unpublished].freeze

    belongs_to :site, class_name: "Cms::Site", inverse_of: :webhooks

    has_many :deliveries,
             class_name: "Cms::WebhookDelivery",
             foreign_key: :webhook_id,
             inverse_of: :webhook,
             dependent: :destroy

    validates :url, presence: true, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]) }
    validates :events, presence: true
    validate :events_must_be_supported

    scope :active, -> { where(active: true) }
    scope :ordered, -> { order(:url) }

    before_validation :normalize_events

    private

    def normalize_events
      self.events = Array(events).map(&:to_s).reject(&:blank?).uniq
    end

    def events_must_be_supported
      return if events.blank?

      invalid_events = events - EVENTS
      return if invalid_events.empty?

      errors.add(:events, I18n.t("cms.errors.webhook.unsupported_events", events: invalid_events.join(", ")))
    end
  end
end
