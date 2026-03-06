# frozen_string_literal: true

# Configure parameters to be filtered from log files.
Rails.application.config.filter_parameters += %i[
  passw
  password
]
