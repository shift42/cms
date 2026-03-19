# CMS

A mountable Rails CMS engine by [Shift42](https://shift42.io).

Rails-native, straightforward to extend, and easy for content editors to use.

## Compatibility

- Ruby >= 3.1
- Rails >= 7.1 (tested up to 8.x)
- PostgreSQL

## Features

| Feature                                                        | Status |
| -------------------------------------------------------------- | ------ |
| Multi-site support                                             | ✅     |
| Content blocks / StreamField (`Cms::Section`)                  | ✅     |
| Multilingual (locale-scoped translations)                      | ✅     |
| Publishing workflow (draft / published / archived)             | ✅     |
| Soft-delete for pages and sections (`discard` gem)             | ✅     |
| Draft preview URLs (token-based, shareable without auth)       | ✅     |
| Page tree (parent/child hierarchy)                             | ✅     |
| Media management (images + documents)                          | ✅     |
| Reusable sections across pages + standalone admin library      | ✅     |
| Form fields + submission capture + email notification          | ✅     |
| Full-text search (title + slug, ilike/unaccent)                | ✅     |
| Headless JSON API v1 (API key auth)                            | ✅     |
| Webhooks (HMAC-signed, per status change, delivery log)        | ✅     |
| Engine-owned English I18n defaults                             | ✅     |
| Host app extension points (`Cms.setup`)                        | ✅     |

## Installation

Add to your host app's `Gemfile`:

```ruby
gem "cms", git: "https://github.com/shift42/cms"
```

Install and migrate:

```bash
bundle install
bin/rails active_storage:install  # skip if already installed
bin/rails generate cms:install
bin/rails db:migrate
```

Mount in `config/routes.rb`:

```ruby
mount Cms::Engine, at: "/cms"
```

Copy engine views into your host app (for Hyper/admin customisation, etc):

```bash
# Copy all CMS views
bin/rails generate cms:views

# Copy only admin/public/mailer views
bin/rails generate cms:views admin
bin/rails generate cms:views public
bin/rails generate cms:views mailer

# Or select scopes explicitly
bin/rails generate cms:views -v admin public
```

## Configuration

Create `config/initializers/cms.rb`:

```ruby
Cms.setup do |config|
  # Public/API controllers inherit from this host controller
  config.parent_controller = "ApplicationController"

  # Required: admin inherits from a host app controller that already handles
  # authentication/authorization for the CMS admin area
  config.admin_parent_controller = "Admin::BaseController"

  # Optional for public/API if you resolve sites via URL slug, subdomain,
  # or X-CMS-SITE-SLUG. Required for admin once any Cms::Site exists.
  config.current_site_resolver = ->(controller) { controller.current_organization&.cms_site }

  # Optional: image renditions (used by cms_image_tag helper)
  config.image_renditions = {
    thumb: "300x200",
    hero:  "1200x630"
  }

  # Optional: notification email for form submissions
  config.form_submission_email = ->(page) { "admin@example.com" }

  # Optional: sender address for outgoing CMS mailers (defaults to "noreply@example.com")
  config.mailer_from = "cms@myapp.com"

  # Optional: gate admin access — return false/nil to respond with 403
  config.authorize_admin = ->(controller) { controller.current_user&.admin? }

  # Optional: auto-destroy sections that become orphaned after page removal (default: false)
  config.auto_destroy_orphaned_sections = false

  # Optional: replace the page resolver used by public/API requests
  config.page_resolver_class = "Cms::PageResolver"

  # Optional: replace API serializer classes
  config.api_site_serializer_class = "Cms::Api::SiteSerializer"
  config.api_page_serializer_class = "Cms::Api::PageSerializer"
end
```

## Configuration Surface

These are the supported host app extension points today:

| Config key | Signature | Purpose |
|---|---|---|
| `parent_controller` | String class name | Base public/API controller to inherit from |
| `admin_parent_controller` | String class name | Base admin controller to inherit from |
| `current_site_resolver` | `->(controller)` | Host-provided current site resolver; required for admin once sites exist |
| `authorize_admin` | `->(controller)` | Optional RBAC hook; return false/nil to respond 403 |
| `form_submission_email` | `->(page)` | Notification email recipient address |
| `mailer_from` | String | Sender address for CMS mailers (default: `"noreply@example.com"`) |
| `image_renditions` | Hash | Named variant dimensions |
| `page_templates` | Array of strings/symbols | Registers additional public page template keys |
| `page_resolver_class` | String class name / Class | Resolver used by public and API page lookup |
| `api_site_serializer_class` | String class name / Class | Serializer for `GET /api/v1/site` and `GET /api/v1/sites/:site_slug` |
| `api_page_serializer_class` | String class name / Class | Serializer for `GET /api/v1/pages/:slug` and site-scoped page endpoints |
| `admin_layout` | String layout name | Admin layout override |
| `public_layout` | String layout name | Public layout override |
| `auto_destroy_orphaned_sections` | Boolean | Auto-destroy sections that have no remaining page placements (default: `false`) |

Controller class replacement per namespace is not a supported config seam today. Public/API inherit from `parent_controller`, admin inherits from `admin_parent_controller`, and deeper controller replacement should still happen with normal Rails route/controller overrides in the host app.

## Host App Extension

The engine is intentionally CMS-only. It manages content structure, publishing, media, reusable sections, forms, and CMS rendering.

If the host app needs business-specific public behavior such as ecommerce pages, customer login, account areas, or custom data models, implement that in the host app using standard Rails patterns:

- add host app routes before or alongside the mounted CMS engine
- use host app controllers and views for business-specific pages
- query host app models directly from the host app
- override engine views or controllers only when CMS behavior itself needs to change
- reuse CMS sections or rendered content inside host app pages when helpful

The CMS engine should not know about host concepts such as products, carts, customers, orders, or accounts.

## Locales

Engine-owned UI strings live in `config/locales/en.yml` under `cms.*`.

- Host apps can override or extend them with normal Rails locale files such as `config/locales/el.yml`.
- Public and API locale resolution is explicit: `Cms::PageResolver` returns the chosen locale, and controllers apply it with `I18n.with_locale`.
- Public and API page lookup uses `config.page_resolver_class`, which defaults to `Cms::PageResolver`.
- Public form errors and notices are translated through I18n, so host apps can localize validation and flash output without monkey-patching engine code.

## Content Blocks (StreamField)

Register custom block types in your host app:

```ruby
Cms::Section::KindRegistry.register(
  "my_custom_block",
  partial:     "cms/sections/my_custom_block",
  block_class: MyApp::MyCustomBlock
)
```

Block classes inherit from `Cms::Section::BlockBase` and declare typed settings:

```ruby
class MyApp::MyCustomBlock < Cms::Section::BlockBase
  settings_schema do
    field :background_color, type: :string,  default: "#ffffff"
    field :columns,          type: :integer, default: 3
  end
end
```

## Reusable Sections

Sections are site-scoped reusable content blocks that can be attached to multiple pages.
They can be managed centrally in the admin section library and then attached where needed.

Built-in image sections reference `Cms::Image` records from the CMS media library via `settings["image_id"]` instead of storing raw URLs.

Use the `cms_sections` helper in views when you need to list reusable sections by kind:

```erb
<% cms_sections(kind: "cta").each do |section| %>
  <%= render_section(section) %>
<% end %>
```

## Page Templates

`Cms::Page#template_key` drives public page rendering as a presentation concern.

Public pages render through a shared shell at `cms/public/pages/show`, which then resolves a template partial at:

- `cms/public/pages/templates/_<template_key>.html.erb`
- fallback: `cms/public/pages/templates/_standard.html.erb`

The engine ships `standard`, `landing`, `form`, and `custom` template partials. Host apps can override any of them with normal Rails view overrides by placing files at the same paths in `app/views`.

This keeps page templates simple and maintainable:

- routes stay stable
- controllers stay shared
- `template_key` stays presentation-only
- host apps can customize page types without replacing the full public rendering flow

## Headless API

The JSON API is available at `/api/v1/` and requires a Bearer token.
Create API keys in the admin UI (`/admin/api_keys`).

```bash
curl -H "Authorization: Bearer YOUR_TOKEN" \
     https://yourapp.com/cms/api/v1/pages/about
```

Endpoints:

- `GET /api/v1/site` — site info + published pages
- `GET /api/v1/pages/:slug` — single page resource with sections
- `GET /api/v1/pages/:slug?include_site=true` — page resource plus lightweight site metadata
- `GET /api/v1/sites/:site_slug` — (multi-site) site info
- `GET /api/v1/sites/:site_slug/pages/:slug` — (multi-site) page

## Webhooks

Configure webhooks in the admin UI. Each webhook receives a HMAC-signed POST:

```
POST https://yourapp.com/webhook-receiver
X-CMS-Event: page.published
X-CMS-Signature: sha256=<hex>
Content-Type: application/json
```

Supported events: `page.published`, `page.unpublished`.

Verify the signature in your receiver:

```ruby
expected = "sha256=#{OpenSSL::HMAC.hexdigest('SHA256', YOUR_SECRET, request.body.read)}"
ActiveSupport::SecurityUtils.secure_compare(expected, request.headers['X-CMS-Signature'])
```

## Routes

| Path | Description |
|---|---|
| `/admin/` | Admin UI |
| `/api/v1/` | Headless JSON API (requires API key) |
| `/sites/:site_slug/` | Public SSR (multi-site) |
| `/` and `/*slug` | Public SSR (single-site) |

## Notes

- Admin does not guess a site. If no `Cms::Site` records exist yet it redirects to `new_admin_site_path`; otherwise it expects `config.current_site_resolver` to return a `Cms::Site`.
- Public/API site resolution supports `config.current_site_resolver`, `params[:site_slug]`, `X-CMS-SITE-SLUG`, or first subdomain.
- API serialization is handled by `config.api_site_serializer_class` and `config.api_page_serializer_class`, which default to `Cms::Api::SiteSerializer` and `Cms::Api::PageSerializer`.
- Navigation rendering uses `header_nav` and `footer_nav` page scopes.
- `template_key` selects `cms/public/pages/templates/<template_key>` with fallback to `standard`, so host apps can override page presentation per template key.
- Page hierarchy is a simple parent/child adjacency list and is intentionally optimized for modest marketing-style site trees, not large catalog trees.
- Revisions and snippets are not part of the current engine architecture. Reusable content is centered on `Cms::Section` and `Cms::PageSection`.

## Development

```bash
# Run tests (uses spec/cms_app dummy app)
bundle exec rspec

# Run linter
bin/rubocop

# Console in dummy app
cd spec/cms_app && bin/rails console

# Run dummy app server
cd spec/cms_app && bin/rails server
```

## License

MIT. See [LICENSE](MIT-LICENSE).
