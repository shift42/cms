# frozen_string_literal: true

module Cms
  class ApplicationMailer < ActionMailer::Base
    default from: -> { Cms.config.mailer_from.presence || "noreply@example.com" }
    layout "mailer"
    helper Cms::ApplicationHelper
  end
end
