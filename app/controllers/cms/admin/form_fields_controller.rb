# frozen_string_literal: true

module Cms
  module Admin
    class FormFieldsController < BaseController
      before_action :set_page
      before_action :set_field, only: %i[edit update destroy]

      def index
        @fields = @page.form_fields.ordered
      end

      def new
        @field = @page.form_fields.build(position: @page.form_fields.count)
      end

      def edit; end

      def create
        @field = @page.form_fields.build(field_params)

        if @field.save
          redirect_to admin_page_form_fields_path(@page), notice: t("cms.notices.field_added")
        else
          render :new, status: :unprocessable_content
        end
      end

      def update
        @field.assign_attributes(field_params)

        if @field.save
          redirect_to admin_page_form_fields_path(@page), notice: t("cms.notices.field_updated")
        else
          render :edit, status: :unprocessable_content
        end
      end

      def destroy
        @field.destroy
        redirect_to admin_page_form_fields_path(@page), notice: t("cms.notices.field_removed")
      end

      def sort
        Array(params[:field_ids]).each_with_index do |id, position|
          @page.form_fields.find(id).update!(position: position)
        end
        head :ok
      end

      private

      def set_page
        @page = current_site.pages.find(params[:page_id])
      end

      def set_field
        @field = @page.form_fields.find(params[:id])
      end

      def field_params
        params.fetch(:cms_form_field, params.fetch(:form_field, ActionController::Parameters.new))
              .permit(
                :kind, :label, :field_name, :placeholder, :hint, :required, :position,
                options: []
              )
      end
    end
  end
end
