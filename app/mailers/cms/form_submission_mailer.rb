# frozen_string_literal: true

module Cms
  class FormSubmissionMailer < ApplicationMailer
    def notify(submission, recipient_email)
      @submission = submission
      @page = submission.page
      @fields = @page.form_fields.ordered

      mail(
        to: recipient_email,
        subject: I18n.t("cms.mailers.form_submission.subject", page_title: @page.display_title)
      )
    end
  end
end
