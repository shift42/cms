# frozen_string_literal: true

Cms.setup do |config|
  # Public/API controllers inherit from this host controller.
  config.parent_controller = "ApplicationController"

  # Required for admin in production: point this at a host controller that
  # already enforces authentication and authorization for CMS access.
  config.admin_parent_controller = "Admin::BaseController"

  # Optional for public/API requests when you use site slugs, headers, or
  # subdomains. Required for admin once any Cms::Site exists.
  config.current_site_resolver = ->(controller) { controller.current_organization&.cms_site }

  # Optional: replace the public/API page lookup service.
  # config.page_resolver_class = "Cms::PageResolver"

  # Optional: replace API serialization classes.
  # config.api_site_serializer_class = "Cms::Api::SiteSerializer"
  # config.api_page_serializer_class = "Cms::Api::PageSerializer"
end
