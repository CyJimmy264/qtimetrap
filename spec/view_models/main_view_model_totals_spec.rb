# frozen_string_literal: true

require 'spec_helper'

RSpec.describe QTimetrap::ViewModels::MainViewModel do
  include_context :main_view_model_setup

  let(:monday) { Date.new(2026, 3, 2) }
  let(:inside_week_entry) do
    QTimetrap::Models::TimeEntry.new(
      id: 10,
      note: 'inside',
      sheet: 'acme|core',
      start_time: Time.new(2026, 3, 3, 10, 0, 0),
      end_time: Time.new(2026, 3, 3, 11, 0, 0)
    )
  end
  let(:outside_week_entry) do
    QTimetrap::Models::TimeEntry.new(
      id: 11,
      note: 'outside',
      sheet: 'acme|core',
      start_time: Time.new(2026, 2, 20, 10, 0, 0),
      end_time: Time.new(2026, 2, 20, 11, 30, 0)
    )
  end

  before do
    allow(Date).to receive(:today).and_return(monday)
    allow(gateway).to receive(:entries).and_return([inside_week_entry, outside_week_entry])
  end

  it 'computes weekly and total summaries and builds entry nodes' do
    view_model.refresh!

    expect(view_model.week_total_seconds).to eq(3600)
    expect(view_model.total_seconds).to eq(9000)
    expect(view_model.summary_line).to eq('Week total: 01:00:00 | Total: 02:30:00')
    expect(view_model.entry_nodes).to be_a(Array)
    expect(view_model.entry_nodes).not_to be_empty
  end
end
