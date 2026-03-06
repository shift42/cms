# frozen_string_literal: true

module Cms
  module Admin
    class DocumentsController < BaseController
      before_action :set_document, only: %i[edit update destroy]

      def index
        @documents = current_site.documents.ordered
      end

      def new
        @document = current_site.documents.build
      end

      def edit; end

      def create
        @document = current_site.documents.build(document_params)

        if @document.save
          redirect_to admin_documents_path, notice: t("cms.notices.document_uploaded")
        else
          render :new, status: :unprocessable_content
        end
      end

      def update
        @document.assign_attributes(document_params)

        if @document.save
          redirect_to admin_documents_path, notice: t("cms.notices.document_updated")
        else
          render :edit, status: :unprocessable_content
        end
      end

      def destroy
        @document.file.purge_later
        @document.destroy
        redirect_to admin_documents_path, notice: t("cms.notices.document_deleted")
      end

      private

      def set_document
        @document = current_site.documents.find(params[:id])
      end

      def document_params
        params.fetch(:cms_document, params.fetch(:document, ActionController::Parameters.new))
              .permit(:title, :description, :file)
      end
    end
  end
end
