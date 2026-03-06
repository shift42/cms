# frozen_string_literal: true

module Cms
  class WebhookDelivery < ApplicationRecord
    self.table_name = "cms_webhook_deliveries"

    belongs_to :webhook, class_name: "Cms::Webhook", inverse_of: :deliveries

    scope :ordered, -> { order(delivered_at: :desc) }
    scope :recent,  -> { ordered.limit(50) }
  end
end
