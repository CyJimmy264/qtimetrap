# frozen_string_literal: true

module TimetrapGatewayHelpers
  def stub_timetrap_api!
    stub_const('Timetrap', Module.new)
    Timetrap.const_set(:Entry, Class.new)
    Timetrap.const_set(:Timer, Class.new)
  end
end

RSpec.configure do |config|
  config.include TimetrapGatewayHelpers
end
