# frozen_string_literal: true

require 'spec_helper'

RSpec.describe QTimetrap::ViewModels::MainViewModel do
  include_context :main_view_model_setup

  let(:entry_acme_ops) do
    QTimetrap::Models::TimeEntry.new(
      id: 3,
      note: 'ops task',
      sheet: 'acme|ops',
      start_time: Time.now - 900,
      end_time: Time.now
    )
  end

  before do
    allow(gateway).to receive(:entries).and_return([entry_today, entry_acme_ops, entry_other_project])
  end

  it 'filters entry nodes by selected tasks' do
    select_project_tasks('acme', ['ops'])
    expect_project_labels_to_include_only('acme | ops', excluding: 'acme | core')
  end

  it 'disables task filtering when multiple projects are selected' do
    select_multiple_projects_and_tasks
    expect_task_filter_to_be_disabled
  end

  it 'orders task names by most recent entry first' do
    stub_entries_with_newer_acme_task
    view_model.refresh!
    view_model.select_project('acme')
    expect(view_model.task_names_for_selected_project).to eq(%w[deploy ops core])
  end

  private

  def select_project_tasks(project, tasks)
    view_model.refresh!
    view_model.select_project(project)
    view_model.select_tasks(tasks)
  end

  def project_labels_for_entry_nodes
    view_model.entry_nodes
      .flat_map { |week| week.fetch(:children) }
      .flat_map { |day| day.fetch(:children) }
      .map { |project| project.fetch(:label) }
      .join(' ')
  end

  def expect_project_labels_to_include_only(included_label, excluding:)
    labels = project_labels_for_entry_nodes
    expect(labels).to include(included_label)
    expect(labels).not_to include(excluding)
  end

  def select_multiple_projects_and_tasks
    view_model.refresh!
    view_model.select_projects(%w[acme internal], primary_project: 'internal')
    view_model.select_tasks(['ops'])
  end

  def expect_task_filter_to_be_disabled
    expect(view_model.selected_tasks).to eq([])
    expect(view_model.task_names_for_selected_project).to eq([])
  end

  def stub_entries_with_newer_acme_task
    acme_newer = QTimetrap::Models::TimeEntry.new(
      id: 4,
      note: 'later',
      sheet: 'acme|deploy',
      start_time: Time.now + 60,
      end_time: Time.now + 120
    )
    allow(gateway).to receive(:entries).and_return([entry_today, entry_acme_ops, acme_newer, entry_other_project])
  end
end
