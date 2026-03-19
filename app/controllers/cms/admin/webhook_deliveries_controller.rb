# frozen_string_literal: true

module Cms
  module Admin
    class WebhookDeliveriesController < BaseController
      before_action :set_webhook

      def index
        @deliveries = @webhook.deliveries.recent
      end

      private

      def set_webhook
        @webhook = current_site.webhooks.find(params[:webhook_id])
      end
    end
  end
end
