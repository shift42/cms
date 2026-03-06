# frozen_string_literal: true

module Cms
  module Public
    class FormSubmissionsController < BaseController
      include Cms::SiteResolvable
      include Cms::Public::PageRendering
      include Cms::Public::PagePaths

      def create
        @site = find_site!
        @page = @site.published_pages.includes(:form_fields, :page_translations, :localised,
                                               { page_sections: :section },
                                               { hero_image_attachment: :blob }).find(params[:page_id])
        @fields = @page.form_fields.ordered
        data = build_submission_data

        @submission = @page.form_submissions.build(
          data: data,
          ip_address: request.remote_ip
        )

        if @submission.save
          notify_by_email(@submission)
          redirect_back(
            fallback_location: public_site_page_path_for(@site, @page),
            notice: t("cms.notices.form_submission_sent")
          )
        else
          I18n.with_locale(@site.default_locale) do
            assign_public_page(site: @site, page: @page)
            render template: "cms/public/pages/show", status: :unprocessable_content
          end
        end
      rescue ActiveRecord::RecordNotFound
        render plain: t("cms.errors.page_not_found"), status: :not_found
      end

      private

      def build_submission_data
        @fields.to_h do |field|
          [field.field_name, normalized_submission_value(field)]
        end
      end

      def normalized_submission_value(field)
        params.dig(:submission, field.field_name)
      end

      def notify_by_email(submission)
        return unless Cms.config.form_submission_email

        email = Cms.config.form_submission_email.call(@page)
        return if email.blank?

        Cms::FormSubmissionMailer.notify(submission, email).deliver_later
      rescue StandardError
        # Mailer failures must never break form submission
      end
    end
  end
end
