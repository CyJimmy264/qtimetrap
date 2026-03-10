# frozen_string_literal: true

require 'spec_helper'

RSpec.describe QTimetrap::ViewModels::MainViewModel do
  include_context :main_view_model_setup

  it 'loads entries and keeps ALL selected by default' do
    view_model.refresh!
    expect(view_model.entries.size).to eq(2)
    expect(view_model.selected_project).to eq('* ALL')
    expect(view_model.selected_projects).to eq(['* ALL'])
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

  it 'filters by multiple selected projects' do
    view_model.refresh!
    view_model.select_projects(%w[acme internal], primary_project: 'internal')

    expect(view_model.filtered_entries.map(&:project)).to contain_exactly('acme', 'internal')
    expect(view_model.selected_projects).to eq(%w[acme internal])
    expect(view_model.selected_project).to eq('internal')
  end

  it 'filters by selected tasks within selected project' do
    view_model.refresh!
    view_model.select_project('acme')
    view_model.select_tasks(['core'])

    expect(view_model.filtered_entries.map(&:task)).to eq(['core'])
  end

  it 'clears selected tasks when project changes' do
    view_model.refresh!
    view_model.select_project('acme')
    view_model.select_tasks(['core'])
    view_model.select_project('internal')

    expect(view_model.selected_tasks).to eq([])
  end

  it 'sets current task to latest task of selected project' do
    latest_acme = QTimetrap::Models::TimeEntry.new(
      id: 3,
      note: 'latest',
      sheet: 'acme|deploy',
      start_time: Time.now + 60,
      end_time: Time.now + 120
    )
    allow(gateway).to receive(:entries).and_return([entry_today, latest_acme, entry_other_project])

    view_model.refresh!
    view_model.select_project('acme')

    expect(view_model.current_sheet_input).to eq('deploy')
  end
end
