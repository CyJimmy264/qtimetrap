# frozen_string_literal: true

require 'spec_helper'

RSpec.describe QTimetrap::Services::TimetrapGateway do
  subject(:gateway) { described_class.new }

  before do
    stub_timetrap_api!
  end

  it 'delegates start to timer API' do
    allow(Timetrap::Timer).to receive(:current_sheet=)
    allow(Timetrap::Timer).to receive(:start)
    gateway.start('focus')
    expect(Timetrap::Timer).to have_received(:current_sheet=).with('focus')
    expect(Timetrap::Timer).to have_received(:start).with('')
  end

  it 'delegates stop to timer API with active entry' do
    active = { id: 77 }
    allow(Timetrap::Timer).to receive(:active_entry).and_return(active)
    allow(Timetrap::Timer).to receive(:stop)
    gateway.stop
    expect(Timetrap::Timer).to have_received(:stop).with(active)
  end
end
