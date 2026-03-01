# frozen_string_literal: true

require 'spec_helper'

RSpec.describe QTimetrap::Services::TimetrapGatewayLogger do
  it 'uses ~/.local/log/qtimetrap/timetrap_gateway.log by default' do
    path = described_class::DEFAULT_LOG_PATH

    expect(path).to end_with('/.local/log/qtimetrap/timetrap_gateway.log')
  end
end
