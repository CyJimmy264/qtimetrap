# frozen_string_literal: true

require 'spec_helper'

RSpec.describe QTimetrap::Services::TimetrapGateway do
  subject(:gateway) { described_class.new }

  it 'returns nil for type errors in parse_time' do
    expect(gateway.send(:parse_time, {})).to be_nil
  end
end
