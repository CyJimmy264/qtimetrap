# frozen_string_literal: true

require 'spec_helper'

RSpec.describe QTimetrap::Views::MainWindow do
  include_context :main_window_qt_boot
  include_context :main_window_setup
  include_context :main_window_cleanup

  it 'switches theme at runtime from toolbar button' do
    main_window.send(:render!)
    expect(theme_button.text.to_s).to eq('THEME: LIGHT')
    theme_button.click
    expect(theme_button.text.to_s).to eq('THEME: DARK')
    expect(qt_window.style_sheet.to_s).to include('#0f172a')
    expect(settings_store).to have_received(:write_theme_name).with('dark')
  end

  it 'updates selected project on sidebar project click' do
    main_window.send(:render!)
    button_with_text('acme').click
    expect(view_model).to have_received(:select_projects).with(['acme'], primary_project: 'acme', sync_current_fields: true)
    expect(view_model).to have_received(:current_project_name=).with('acme')
  end

  it 'updates current project field when project is selected in sidebar' do
    allow(view_model).to receive_messages(
      selected_project: '* ALL',
      current_project_name: 'acme',
      project_names: ['* ALL', 'acme']
    )

    main_window.send(:render!)
    button_with_text('acme').click

    project_input = find_widget(qt_window, 'project_input')
    expect(project_input.text.to_s).to eq('acme')
  end

  it 'fills current project input from clicked sidebar project even when vm field is blank' do
    allow(view_model).to receive_messages(
      selected_project: '* ALL',
      current_project_name: '',
      project_names: ['* ALL', 'acme']
    )

    main_window.send(:render!)
    button_with_text('acme').click

    project_input = find_widget(qt_window, 'project_input')
    expect(project_input.text.to_s).to eq('acme')
  end

  it 'does not clear project input on refresh when vm current project is blank' do
    allow(view_model).to receive_messages(
      selected_project: 'acme',
      current_project_name: 'acme',
      project_names: ['* ALL', 'acme']
    )
    main_window.send(:render!, sync_sheet: true)
    project_input = find_widget(qt_window, 'project_input')
    expect(project_input.text.to_s).to eq('acme')

    allow(view_model).to receive(:current_project_name).and_return('')
    main_window.send(:render!, sync_sheet: true)

    expect(project_input.text.to_s).to eq('acme')
  end

  it 'updates current task field to latest project task on project click' do
    allow(view_model).to receive_messages(
      selected_project: '* ALL',
      current_sheet_input: 'deploy',
      project_names: ['* ALL', 'acme']
    )

    main_window.send(:render!)
    button_with_text('acme').click

    task_input = find_widget(qt_window, 'task_input')
    expect(task_input.text.to_s).to eq('deploy')
  end

  it 'renders task shortcuts for selected non-all project and fills input on click' do
    allow(view_model).to receive_messages(
      selected_project: 'acme',
      task_names_for_selected_project: %w[core ops]
    )

    main_window.send(:render!)
    button_with_text('core').click

    task_input = find_widget(qt_window, 'task_input')
    expect(task_input.text.to_s).to eq('core')
  end

  it 'does not render task shortcuts when selected project is * ALL' do
    allow(view_model).to receive_messages(
      selected_project: '* ALL',
      task_names_for_selected_project: []
    )

    main_window.send(:render!)

    task_buttons = widgets_of_type(qt_window, QPushButton).select { |button| button.object_name == 'task_button' }
    expect(task_buttons).to be_empty
  end

  it 'renders archive toggle button state from view model' do
    allow(view_model).to receive(:archive_mode?).and_return(true)

    main_window.send(:render!)
    archive_toggle = find_widget(qt_window, 'sidebar_archive_toggle')

    expect(archive_toggle).not_to be_nil
    expect(archive_toggle.is_checked).to be(true)
  end

  it 'toggles archive-only mode from sidebar trash button' do
    main_window.send(:render!)
    archive_toggle = find_widget(qt_window, 'sidebar_archive_toggle')

    archive_toggle.click

    expect(view_model).to have_received(:archive_mode=).with(true)
  end

  it 'uses single-select for project buttons by default' do
    allow(view_model).to receive_messages(
      selected_project: '* ALL',
      selected_projects: ['* ALL'],
      project_names: ['* ALL', 'acme', 'internal']
    )
    allow(view_model).to receive(:select_projects) do |projects, primary_project:, **|
      allow(view_model).to receive_messages(selected_projects: projects, selected_project: primary_project)
    end
    allow(QApplication).to receive(:keyboard_modifiers).and_return(0)

    main_window.send(:render!)
    acme = button_with_text('acme')
    internal = button_with_text('internal')

    acme.click
    internal.click

    expect(acme.is_checked).to be(false)
    expect(internal.is_checked).to be(true)
  end

  it 'allows multi-select with Ctrl for project buttons' do
    allow(view_model).to receive_messages(
      selected_project: '* ALL',
      selected_projects: ['* ALL'],
      project_names: ['* ALL', 'acme', 'internal']
    )
    allow(view_model).to receive(:select_projects) do |projects, primary_project:, **|
      allow(view_model).to receive_messages(selected_projects: projects, selected_project: primary_project)
    end

    main_window.send(:render!)
    acme = button_with_text('acme')
    internal = button_with_text('internal')

    allow(QApplication).to receive(:keyboard_modifiers).and_return(0)
    acme.click
    allow(QApplication).to receive(:keyboard_modifiers).and_return(Qt::ControlModifier)
    internal.click

    expect(acme.is_checked).to be(true)
    expect(internal.is_checked).to be(true)
  end

  it 'selects project range with Shift from last anchor' do
    allow(view_model).to receive_messages(
      selected_project: '* ALL',
      selected_projects: ['* ALL'],
      project_names: ['* ALL', 'acme', 'internal', 'ops']
    )
    allow(view_model).to receive(:select_projects) do |projects, primary_project:, **|
      allow(view_model).to receive_messages(selected_projects: projects, selected_project: primary_project)
    end

    main_window.send(:render!)
    acme = button_with_text('acme')
    internal = button_with_text('internal')
    ops = button_with_text('ops')

    allow(QApplication).to receive(:keyboard_modifiers).and_return(0)
    acme.click
    allow(QApplication).to receive(:keyboard_modifiers).and_return(Qt::ShiftModifier)
    ops.click

    expect(acme.is_checked).to be(true)
    expect(internal.is_checked).to be(true)
    expect(ops.is_checked).to be(true)
  end

  it 'uses single-select for task buttons by default' do
    allow(view_model).to receive_messages(
      selected_project: 'acme',
      task_names_for_selected_project: %w[core ops qa]
    )
    allow(QApplication).to receive(:keyboard_modifiers).and_return(0)

    main_window.send(:render!)
    core = button_with_text('core')
    ops = button_with_text('ops')

    core.click
    ops.click

    expect(core.is_checked).to be(false)
    expect(ops.is_checked).to be(true)
  end

  it 'allows multi-select with Ctrl for task buttons' do
    allow(view_model).to receive_messages(
      selected_project: 'acme',
      task_names_for_selected_project: %w[core ops qa]
    )

    main_window.send(:render!)
    core = button_with_text('core')
    ops = button_with_text('ops')

    allow(QApplication).to receive(:keyboard_modifiers).and_return(0)
    core.click
    allow(QApplication).to receive(:keyboard_modifiers).and_return(Qt::ControlModifier)
    ops.click

    expect(core.is_checked).to be(true)
    expect(ops.is_checked).to be(true)
  end

  it 'selects task range with Shift from last anchor' do
    allow(view_model).to receive_messages(
      selected_project: 'acme',
      task_names_for_selected_project: %w[core ops qa ux]
    )

    main_window.send(:render!)
    core = button_with_text('core')
    ops = button_with_text('ops')
    qa = button_with_text('qa')
    ux = button_with_text('ux')

    allow(QApplication).to receive(:keyboard_modifiers).and_return(0)
    core.click
    allow(QApplication).to receive(:keyboard_modifiers).and_return(Qt::ShiftModifier)
    qa.click

    expect(core.is_checked).to be(true)
    expect(ops.is_checked).to be(true)
    expect(qa.is_checked).to be(true)
    expect(ux.is_checked).to be(false)
  end

  it 'keeps full long task text and tooltip in sidebar buttons' do
    long_task = 'very-long-task-name-with-details-and-suffix-1234567890'
    allow(view_model).to receive_messages(
      selected_project: 'acme',
      task_names_for_selected_project: [long_task]
    )

    main_window.send(:render!)
    task_button = widgets_of_type(qt_window, QPushButton).find { |button| button.object_name == 'task_button' }

    expect(task_button.text.to_s).to eq(long_task)
    expect(task_button.tool_tip.to_s).to eq(long_task)
  end

  it 'keeps current task/project inputs unchanged on sidebar project click while running' do
    allow(view_model).to receive_messages(
      selected_project: '* ALL',
      current_sheet_input: 'running-task',
      current_project_name: 'running-project',
      project_names: ['* ALL', 'acme', 'internal'],
      running_current_sheet?: true
    )

    main_window.send(:render!)
    before_task = find_widget(qt_window, 'task_input').text.to_s
    before_project = find_widget(qt_window, 'project_input').text.to_s
    button_with_text('internal').click

    task_input = find_widget(qt_window, 'task_input')
    project_input = find_widget(qt_window, 'project_input')
    expect(task_input.text.to_s).to eq(before_task)
    expect(project_input.text.to_s).to eq(before_project)
    expect(view_model).to have_received(:select_projects)
      .with(['internal'], primary_project: 'internal', sync_current_fields: false)
    expect(view_model).not_to have_received(:current_project_name=).with('internal')
  end

  it 'locks task/project inputs when tracking is running' do
    allow(view_model).to receive(:running_current_sheet?).and_return(true)

    main_window.send(:render!)
    task_input = find_widget(qt_window, 'task_input')
    project_input = find_widget(qt_window, 'project_input')
    expect(task_input.is_read_only).to be(true)
    expect(project_input.is_read_only).to be(true)
  end
end
