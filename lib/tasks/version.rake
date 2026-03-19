# frozen_string_literal: true

namespace :cms do
  desc "Print current gem version"
  task :version do
    puts Cms::VERSION
  end
end
