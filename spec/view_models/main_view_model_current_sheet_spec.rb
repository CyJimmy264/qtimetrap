# frozen_string_literal: true

require 'spec_helper'

RSpec.describe QTimetrap::ViewModels::MainViewModel do
  include_context :main_view_model_setup

  it 'uses running entry sheet for controls fields' do
    allow(gateway).to receive(:entries).and_return([entry_today, running_entry])
    view_model.refresh!
    expect_current_sheet_fields('focus', 'focus', 'deep')
  end

  it 'keeps project label stable while running' do
    started_at = Time.new(2026, 2, 28, 10, 0, 0, '+00:00')
    allow(gateway).to receive_messages(active_started_at: started_at, entries: [running_entry(id: 9, started_at: started_at)])
    view_model.refresh!
    expect(view_model.current_sheet_label(now: started_at + 65)).to eq('focus')
  end

  it 'builds sheet from project and task input for start action' do
    allow(gateway).to receive(:entries).and_return([])
    view_model.refresh!
    view_model.select_project('acme')

    expect(view_model.sheet_for_task_input('deep work')).to eq('acme|deep work')
  end

  it 'updates current project field when selecting sidebar project' do
    view_model.refresh!
    view_model.select_project('acme')

    expect(view_model.current_project_name).to eq('acme')
  end

  it 'updates current task field from selected sidebar task' do
    view_model.refresh!
    view_model.current_task_input = 'review'

    expect(view_model.current_sheet_input).to eq('review')
  end

  it 'supports custom current project input for start sheet composition' do
    view_model.refresh!
    view_model.current_project_name = 'custom-client'

    expect(view_model.sheet_for_task_input('planning')).to eq('custom-client|planning')
  end

  it 'builds sheet from utf-8 project and task without losing text' do
    view_model.refresh!
    view_model.current_project_name = 'проект'
    task = 'задача'

    expect(view_model.sheet_for_task_input(task)).to eq('проект|задача')
  end

  private

  def running_entry(id: 7, started_at: Time.now - 60)
    QTimetrap::Models::TimeEntry.new(
      id: id,
      note: 'n',
      sheet: 'focus|deep',
      start_time: started_at,
      end_time: nil
    )
  end

  def expect_current_sheet_fields(project_name, sheet_label, sheet_input)
    expect(view_model.current_project_name).to eq(project_name)
    expect(view_model.current_sheet_label).to eq(sheet_label)
    expect(view_model.current_sheet_input).to eq(sheet_input)
  end
end
