# frozen_string_literal: true

require 'spec_helper'

RSpec.describe QTimetrap::Services::TimetrapGateway do
  subject(:gateway) { described_class.new }

  before do
    stub_timetrap_api!
  end

  it 'returns start time from active entry via API' do
    start_time = Time.new(2026, 2, 28, 9, 0, 0, '+00:00')
    allow(Timetrap::Timer).to receive(:active_entry).and_return({ start: start_time })
    expect(gateway.active_started_at).to eq(start_time)
  end

  it 'returns nil when no active entry via API' do
    allow(Timetrap::Timer).to receive(:active_entry).and_return(nil)
    expect(gateway.active_started_at).to be_nil
  end
end
