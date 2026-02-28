# frozen_string_literal: true

require 'spec_helper'

RSpec.describe QTimetrap::ViewModels::MainViewModel do
  include_context :main_view_model_setup

  it 'loads entries and keeps ALL selected by default' do
    view_model.refresh!
    expect(view_model.entries.size).to eq(2)
    expect(view_model.selected_project).to eq('* ALL')
  end

  it 'returns sorted project names with ALL first' do
    view_model.refresh!
    expect(view_model.project_names).to eq(['* ALL', 'acme', 'internal'])
  end

  it 'filters by selected project' do
    view_model.refresh!
    view_model.select_project('acme')
    expect(view_model.filtered_entries.map(&:project)).to eq(['acme'])
  end

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
end
