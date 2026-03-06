# frozen_string_literal: true

module Cms
  module Admin
    class WebhooksController < BaseController
      before_action :set_webhook, only: %i[edit update destroy]

      def index
        @webhooks = current_site.webhooks.order(created_at: :desc)
      end

      def new
        @webhook = current_site.webhooks.build
      end

      def create
        @webhook = current_site.webhooks.build(webhook_params)
        if @webhook.save
          redirect_to admin_webhooks_path, notice: t("cms.notices.webhook_created")
        else
          render :new, status: :unprocessable_content
        end
      end

      def edit; end

      def update
        if @webhook.update(webhook_params)
          redirect_to admin_webhooks_path, notice: t("cms.notices.webhook_updated")
        else
          render :edit, status: :unprocessable_content
        end
      end

      def destroy
        @webhook.destroy
        redirect_to admin_webhooks_path, notice: t("cms.notices.webhook_deleted")
      end

      private

      def set_webhook
        @webhook = current_site.webhooks.find(params[:id])
      end

      def webhook_params
        params.require(:webhook).permit(:url, :secret, :active, events: [])
      end
    end
  end
end
