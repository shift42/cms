# frozen_string_literal: true

module Cms
  module Admin
    class ApiKeysController < BaseController
      before_action :set_api_key, only: %i[edit update destroy]

      def index
        @api_keys = current_site.api_keys.order(created_at: :desc)
      end

      def new
        @api_key = current_site.api_keys.build
      end

      def create
        @api_key = current_site.api_keys.build(api_key_params)
        if @api_key.save
          @new_token = @api_key.token
          render :create
        else
          render :new, status: :unprocessable_content
        end
      end

      def edit; end

      def update
        if @api_key.update(api_key_params.except(:token))
          redirect_to admin_api_keys_path, notice: t("cms.notices.api_key_updated")
        else
          render :edit, status: :unprocessable_content
        end
      end

      def destroy
        @api_key.destroy
        redirect_to admin_api_keys_path, notice: t("cms.notices.api_key_deleted")
      end

      private

      def set_api_key
        @api_key = current_site.api_keys.find(params[:id])
      end

      def api_key_params
        params.require(:api_key).permit(:name, :active)
      end
    end
  end
end
