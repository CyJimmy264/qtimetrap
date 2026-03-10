# frozen_string_literal: true

require 'spec_helper'

RSpec.describe QTimetrap::ViewModels::MainViewModel do
  include_context :main_view_model_setup

  it 'loads entries and keeps ALL selected by default' do
    view_model.refresh!
    expect_default_selection_after_refresh
  end

  it 'returns project names ordered by most recent entry with ALL first' do
    stub_entries_with_newer_internal_project
    view_model.refresh!
    expect(view_model.project_names).to eq(['* ALL', 'internal', 'acme'])
  end

  it 'filters by selected project' do
    refresh_and_select_project('acme')
    expect(view_model.filtered_entries.map(&:project)).to eq(['acme'])
  end

  it 'filters by multiple selected projects' do
    refresh_and_select_projects(%w[acme internal], primary_project: 'internal')
    expect_multiple_project_filter_state
  end

  it 'filters by selected tasks within selected project' do
    refresh_and_select_project_tasks('acme', ['core'])
    expect(view_model.filtered_entries.map(&:task)).to eq(['core'])
  end

  it 'clears selected tasks when project changes' do
    refresh_and_select_project_tasks('acme', ['core'])
    view_model.select_project('internal')
    expect(view_model.selected_tasks).to eq([])
  end

  it 'sets current task to latest task of selected project' do
    stub_entries_with_latest_acme_task
    refresh_and_select_project('acme')
    expect(view_model.current_sheet_input).to eq('deploy')
  end

  private

  def expect_default_selection_after_refresh
    expect(view_model.entries.size).to eq(2)
    expect(view_model.selected_project).to eq('* ALL')
    expect(view_model.selected_projects).to eq(['* ALL'])
  end

  def stub_entries_with_newer_internal_project
    newer_internal = QTimetrap::Models::TimeEntry.new(
      id: 3,
      note: 'latest',
      sheet: 'internal|deploy',
      start_time: Time.now + 60,
      end_time: Time.now + 120
    )
    allow(gateway).to receive(:entries).and_return([entry_today, entry_other_project, newer_internal])
  end

  def refresh_and_select_project(project)
    view_model.refresh!
    view_model.select_project(project)
  end

  def refresh_and_select_projects(projects, primary_project:)
    view_model.refresh!
    view_model.select_projects(projects, primary_project: primary_project)
  end

  def expect_multiple_project_filter_state
    expect(view_model.filtered_entries.map(&:project)).to contain_exactly('acme', 'internal')
    expect(view_model.selected_projects).to eq(%w[acme internal])
    expect(view_model.selected_project).to eq('internal')
  end

  def refresh_and_select_project_tasks(project, tasks)
    refresh_and_select_project(project)
    view_model.select_tasks(tasks)
  end

  def stub_entries_with_latest_acme_task
    latest_acme = QTimetrap::Models::TimeEntry.new(
      id: 3,
      note: 'latest',
      sheet: 'acme|deploy',
      start_time: Time.now + 60,
      end_time: Time.now + 120
    )
    allow(gateway).to receive(:entries).and_return([entry_today, latest_acme, entry_other_project])
  end
end
