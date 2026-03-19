# frozen_string_literal: true

require "spec_helper"
require "cms/version"

RSpec.describe Cms::VERSION do
  it "has a version number" do
    expect(Cms::VERSION).not_to be_nil
  end
end
