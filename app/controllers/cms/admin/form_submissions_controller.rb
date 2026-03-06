# frozen_string_literal: true

module Cms
  module Admin
    class FormSubmissionsController < BaseController
      before_action :set_page

      def index
        @submissions = @page.form_submissions.recent
        @fields = @page.form_fields.ordered

        respond_to do |format|
          format.html
          format.csv do
            csv = Cms::FormSubmission.to_csv(@submissions, @fields)
            send_data csv,
                      filename: "#{@page.slug}-submissions-#{Date.today}.csv",
                      type: "text/csv"
          end
        end
      end

      def destroy
        @submission = @page.form_submissions.find(params[:id])
        @submission.destroy
        redirect_to admin_page_form_submissions_path(@page), notice: t("cms.notices.submission_deleted")
      end

      private

      def set_page
        @page = current_site.pages.find(params[:page_id])
      end
    end
  end
end
