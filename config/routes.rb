# frozen_string_literal: true

Cms::Engine.routes.draw do
  namespace :admin do
    resource :site, only: %i[new create show edit update]
    resources :sections
    resources :pages do
      member do
        get :preview
      end
      patch "sections/sort", to: "sections#sort", as: :sort_sections
      resources :sections, except: :index
      post "sections/attach", to: "sections#attach", as: :attach_section
      resources :form_fields do
        collection do
          patch :sort
        end
      end
      resources :form_submissions, only: %i[index destroy]
    end
    resources :images
    resources :documents
    resources :api_keys, except: %i[show]
    resources :webhooks, except: %i[show] do
      resources :deliveries, only: :index, controller: "webhook_deliveries"
    end
  end

  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      resources :sites, only: :show, param: :site_slug do
        resources :pages, only: :show, param: :slug
      end
      resource :site, only: :show, controller: :sites
      resources :pages, only: :show, param: :slug
    end
  end

  scope module: :public do
    # Public form submissions
    resources :pages, only: [] do
      resources :form_submissions, only: :create
    end

    # Public multi-site routes (site resolved via URL slug)
    resources :sites, only: :show, param: :site_slug
    get "sites/:site_slug/*slug", to: "sites#show", as: :site_page

    # Draft preview (token-based, no auth required)
    get "preview/:preview_token", to: "previews#show", as: :page_preview

    # Public single-site routes (site resolved via header/subdomain)
    get "/", to: "sites#show", as: :current_site
    get "*slug", to: "sites#show", as: :current_site_page
  end
end
