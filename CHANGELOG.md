# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed

- Public rendering and API locale resolution now return explicit locale data from `Cms::PageResolver`, and controllers apply it with `I18n.with_locale` instead of mutating `I18n.locale` inside services.
- User-facing engine strings now live in `config/locales/en.yml`, allowing host apps to override notices, validation copy, and admin UI text through standard Rails locale files.
- Admin site resolution is now explicit: if no `Cms::Site` records exist, admin redirects to the singular bootstrap flow; if sites exist and no site resolves, the engine raises a configuration error instead of guessing.
- Documentation and install guidance now describe the current engine seams: `Cms::Admin`, `Cms::Public`, `Cms::Api`, locale-aware pages/sections, and `Cms.setup` configuration focused on CMS concerns only.

### Removed

- Revision history and rollback are no longer part of the engine architecture.
- Snippets are no longer part of the engine architecture; reusable content is centered on `Cms::Section` and `Cms::PageSection`.
- Old adapter-style integration guidance for host business domains has been dropped in favor of Rails-native host app routes, controllers, views, and queries.

## [0.1.0] - 2026-03-06

### Added

**Phase 1 — Core Foundation**
- `Cms::Site` model with multi-site support, logo/favicon via ActiveStorage, `default_locale`
- `Cms::Page` model with `page_type` enum (content/landing/product_list/product_show/enquiry), `status` enum (draft/published/archived), nav placement flags
- `Cms::PageTranslation` model with locale-specific title, excerpt, body_rich (ActionText), SEO fields
- Admin CRUD for sites and pages
- Public SSR rendering with `Cms::SiteResolvable` and `Cms::PageResolver`
- JSON API (`/api/`) for headless usage
- Install generator with migration template

**Phase 2 — Content Blocks (StreamField)**
- `Cms::Section` model with `kind` (block type), `position`, `enabled`, `settings` (JSONB)
- `Cms::SectionTranslation` with locale-specific title and body_rich
- `Cms::Section::BlockBase` — typed settings DSL
- `Cms::Section::KindRegistry` — maps kind string to block class + partial
- Built-in blocks: `RichTextBlock`, `ImageBlock`, `HeroBlock`, `CallToActionBlock`
- Admin section CRUD with Turbo Frames + Stimulus drag-sort
- Hotwire: turbo-rails, stimulus-rails, importmap-rails

**Phase 3 — Publishing Workflow**
- `publish_at` scheduled publishing on pages
- `Cms::Revision` — polymorphic page snapshots (JSONB) with restore
- `Cms::PublishScheduledPagesJob` — auto-publishes due pages
- Admin revisions index with one-click restore
- Page preview action (renders public view without layout)

**Phase 4 — Media Management**
- `Cms::Image` model — site-scoped, `has_one_attached :file`, variant helper
- `Cms::Document` model — site-scoped, `has_one_attached :file`
- Admin CRUD for images and documents
- `cms_image_tag` and `cms_document_url` view helpers
- Configurable image renditions via `Cms.config.image_renditions`

**Phase 5 — Snippets**
- `Cms::Snippet` model — site-scoped reusable content blocks with kind registry
- `Cms::SnippetTranslation` with locale-specific title and body_rich
- Built-in snippet kinds: `navigation_item`, `banner`, `testimonial`
- `Cms::Snippet::BlockBase` and `Cms::Snippet::KindRegistry` (same pattern as sections)
- Admin CRUD for snippets
- `cms_snippets(kind:)` view helper

**Phase 6 — Page Tree**
- Self-referential `parent_id` on `cms_pages` (no gem required)
- `ancestors`, `depth`, `descendants` methods on `Cms::Page`
- `scope :root` — pages without a parent
- Admin parent select (excludes self and descendants)
- Indented page tree in admin index

**Phase 7 — Forms**
- `Cms::FormField` model — typed fields (text/email/textarea/select/checkbox/file), positioned, per page
- `Cms::FormSubmission` model — JSONB data capture, CSV export
- Admin form field builder with drag-sort
- Admin form submissions index with CSV download
- Public form submission endpoint
- `Cms::FormSubmissionMailer` notification emails

**Phase 8 — Search**
- `scope :search` on `Cms::Page` — ilike/unaccent on title and slug
- Admin pages search bar

**Phase 10 — Host Adapter API**
- Full `Cms::Configuration` class with adapter lambdas: `current_actor`, `can_manage_cms`, `current_tenant`, `products_scope_for`, `find_product`, `build_enquiry`, `submit_enquiry`, `form_submission_email`, `image_renditions`, `locale_in_path`
- `check_cms_access` before_action in admin — no-op if adapter not configured

**Phase 11 — Internationalisation**
- `Cms::LocaleResolver` service — extracted fallback chain logic
- Translation completeness badges in admin page show view

**Phase 12 — Headless API**
- `Cms::ApiKey` model — token generation (SecureRandom), `active` scope, `touch_last_used!`
- `Cms::Webhook` model — URL validation, JSONB events array
- `Cms::DeliverWebhookJob` — HMAC-signed POST delivery (best-effort)
- `fire_webhooks_on_status_change` after_commit on page status changes
- Versioned API namespace: `/api/v1/` with Bearer token authentication
- Admin CRUD for API keys (token shown once on create) and webhooks

**Phase 14 — OSS Packaging**
- GitHub Actions CI: RuboCop + RSpec across Ruby 3.1/3.2/3.3
- Full README with quickstart, adapter API docs, block/snippet extension guide
- This CHANGELOG

[Unreleased]: https://github.com/shift42/cms/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/shift42/cms/releases/tag/v0.1.0
