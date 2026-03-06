# frozen_string_literal: true

module Cms
  class ApiKey < ApplicationRecord
    self.table_name = "cms_api_keys"

    belongs_to :site, class_name: "Cms::Site", inverse_of: :api_keys

    validates :name, presence: true
    validates :token, presence: true, uniqueness: true

    before_validation :generate_token, on: :create

    scope :active, -> { where(active: true) }
    scope :ordered, -> { order(:name) }

    def touch_last_used!
      update_column(:last_used_at, Time.current)
    end

    private

    def generate_token
      self.token = SecureRandom.hex(32)
    end
  end
end
