# frozen_string_literal: true

module Cms
  class ApplicationController < Cms.parent_controller.constantize
    private

    def page_resolver_class
      Cms.page_resolver_class
    end
  end
end
