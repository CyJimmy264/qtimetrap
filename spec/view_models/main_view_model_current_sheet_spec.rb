# frozen_string_literal: true

require 'spec_helper'

RSpec.describe QTimetrap::ViewModels::MainViewModel do
  include_context :main_view_model_setup

  it 'uses running entry sheet for controls fields' do
    running = QTimetrap::Models::TimeEntry.new(
      id: 7, note: 'n', sheet: 'focus|deep',
      start_time: Time.now - 60, end_time: nil
    )
    allow(gateway).to receive(:entries).and_return([entry_today, running])

    view_model.refresh!

    expect(view_model.current_sheet_label).to eq('focus|deep')
    expect(view_model.current_sheet_input).to eq('focus|deep')
  end

  it 'appends elapsed time to sheet label while running' do
    started_at = Time.new(2026, 2, 28, 10, 0, 0, '+00:00')
    running = QTimetrap::Models::TimeEntry.new(
      id: 9, note: 'n', sheet: 'focus|deep',
      start_time: started_at, end_time: nil
    )
    allow(gateway).to receive(:active_started_at).and_return(started_at)
    allow(gateway).to receive(:entries).and_return([running])

    view_model.refresh!

    expect(view_model.current_sheet_label(now: started_at + 65)).to eq('focus|deep 00:01:05')
  end
end
