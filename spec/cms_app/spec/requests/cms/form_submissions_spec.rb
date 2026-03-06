# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Cms form submissions", type: :request do
  include Cms::Engine.routes.url_helpers

  let!(:site) { create(:cms_site, name: "Docs", slug: "docs", published: true, default_locale: "el") }
  let!(:page) do
    create(:cms_page, :published, site: site, slug: "contact").tap do |record|
      create(:cms_page_translation, page: record, locale: "el", title: "Contact")
    end
  end
  let!(:field) do
    create(:cms_form_field, page: page, field_name: "email", label: "Email", kind: "email", required: true)
  end

  around do |example|
    translations = {
      cms: {
        notices: { form_submission_sent: "Το μήνυμα στάλθηκε." },
        errors: {
          form_submission: { required: "Το %<label>s είναι υποχρεωτικό" }
        },
        public: {
          forms: {
            submission_problem: "Υπήρξε πρόβλημα με την υποβολή σας",
            contact: "Επικοινωνία",
            send: "Αποστολή"
          }
        }
      }
    }
    I18n.backend.store_translations(:el, translations)
    previous_locale = I18n.locale
    I18n.locale = :el
    example.run
  ensure
    I18n.locale = previous_locale
  end

  it "uses host-provided locale translations for validation output" do
    post page_form_submissions_path(page, site_slug: site.slug), params: {
      submission: { email: "" }
    }

    expect(response).to have_http_status(:unprocessable_content)
    expect(response.body).to include("Υπήρξε πρόβλημα με την υποβολή σας")
    expect(response.body).to include("Το Email είναι υποχρεωτικό")
  end

  it "uses host-provided locale translations for success notices" do
    post page_form_submissions_path(page, site_slug: site.slug), params: {
      submission: { email: "person@example.com" }
    }

    expect(response).to redirect_to(site_page_path(site.slug, page.public_path))
    expect(flash[:notice]).to eq("Το μήνυμα στάλθηκε.")
  end
end
