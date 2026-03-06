# frozen_string_literal: true

require "net/http"
require "openssl"

module Cms
  class DeliverWebhookJob < ApplicationJob
    queue_as :default

    def perform(webhook_id, event, payload)
      webhook = Cms::Webhook.find_by(id: webhook_id)
      return unless deliverable?(webhook, event)

      response = build_http_client(webhook.url).request(build_request(webhook, event, payload))
      record_delivery(webhook, event, response: response)
    rescue StandardError => e
      record_delivery(webhook, event, error: e) if webhook
    end

    private

    def deliverable?(webhook, event)
      webhook&.active? && webhook.events.include?(event)
    end

    def build_http_client(url)
      uri = URI.parse(url)

      Net::HTTP.new(uri.host, uri.port).tap do |http|
        http.use_ssl = uri.scheme == "https"
        http.open_timeout = 5
        http.read_timeout = 10
      end
    end

    def build_request(webhook, event, payload)
      body = request_body(payload, event)
      uri = URI.parse(webhook.url)

      Net::HTTP::Post.new(uri.request_uri).tap do |request|
        request["Content-Type"] = "application/json"
        request["X-CMS-Event"] = event
        request["X-CMS-Signature"] = sign(body, webhook.secret) if webhook.secret.present?
        request.body = body
      end
    end

    def request_body(payload, event)
      JSON.generate(payload.merge("event" => event, "timestamp" => Time.current.iso8601))
    end

    def record_delivery(webhook, event, response: nil, error: nil)
      webhook.deliveries.create!(
        event: event,
        response_code: response&.code&.to_i,
        response_body: response&.body.to_s.truncate(2000),
        success: error.nil? && response&.code.to_i.between?(200, 299),
        error_message: error&.message&.truncate(500)
      )
    end

    def sign(body, secret)
      "sha256=#{OpenSSL::HMAC.hexdigest('SHA256', secret, body)}"
    end
  end
end
