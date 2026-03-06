# frozen_string_literal: true

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.es2017-esm.js", preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
