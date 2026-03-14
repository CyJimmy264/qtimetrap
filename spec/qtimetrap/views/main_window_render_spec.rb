# frozen_string_literal: true

require 'spec_helper'

RSpec.describe QTimetrap::Views::MainWindow do
  include_context :main_window_qt_boot
  include_context :main_window_setup
  include_context :main_window_cleanup

  it 'switches theme at runtime from toolbar button' do
    main_window.send(:render!)
    theme_button.click
    expect_dark_theme_applied
  end

  it 'updates selected project on sidebar project click' do
    render_and_click_project('acme')
    expect(view_model).to have_received(:select_projects)
      .with(['acme'], primary_project: 'acme', sync_current_fields: true)
  end

  it 'updates current project field when project is selected in sidebar' do
    stub_sidebar_project_state(project_names: ['* ALL', 'acme'], current_project_name: 'acme')

    render_and_click('acme')

    expect(project_input.text.to_s).to eq('acme')
  end

  it 'fills current project input from clicked sidebar project even when vm field is blank' do
    stub_sidebar_project_state(project_names: ['* ALL', 'acme'], current_project_name: '')

    render_and_click('acme')

    expect(project_input.text.to_s).to eq('acme')
  end

  it 'does not clear project input on refresh when vm current project is blank' do
    render_with_acme_project_input
    rerender_with_blank_project_name
    expect(project_input.text.to_s).to eq('acme')
  end

  it 'updates current task field to latest project task on project click' do
    stub_sidebar_project_state(project_names: ['* ALL', 'acme'], current_sheet_input: 'deploy')

    render_and_click('acme')

    expect(task_input.text.to_s).to eq('deploy')
  end

  it 'renders task shortcuts for selected non-all project and fills input on click' do
    render_task_shortcuts(%w[core ops])
    button_with_text('core').click
    expect(task_input.text.to_s).to eq('core')
  end

  it 'does not render task shortcuts when selected project is * ALL' do
    render_without_task_shortcuts
    expect(task_buttons).to be_empty
  end

  it 'renders archive toggle button state from view model' do
    allow(view_model).to receive(:archive_mode?).and_return(true)
    main_window.send(:render!)
    expect(archive_toggle_checked?).to be(true)
  end

  it 'toggles archive-only mode from sidebar trash button' do
    main_window.send(:render!)
    archive_toggle = find_widget(qt_window, 'sidebar_archive_toggle')

    archive_toggle.click

    expect(view_model).to have_received(:archive_mode=).with(true)
  end

  it 'uses single-select for project buttons by default' do
    stub_sidebar_project_state(project_names: ['* ALL', 'acme', 'internal'])
    allow(QApplication).to receive(:keyboard_modifiers).and_return(0)

    render_and_click('acme')
    button_with_text('internal').click

    expect_button_check_states('acme' => false, 'internal' => true)
  end

  it 'allows multi-select with Ctrl for project buttons' do
    click_project_with_modifiers(first: 'acme', second: 'internal', modifier: Qt::ControlModifier)
    expect_button_check_states('acme' => true, 'internal' => true)
  end

  it 'selects project range with Shift from last anchor' do
    select_project_range('acme', 'ops')
    expect_button_check_states('acme' => true, 'internal' => true, 'ops' => true)
  end

  it 'uses single-select for task buttons by default' do
    render_single_select_tasks(%w[core ops qa])
    click_task_buttons('core', 'ops')
    expect_button_check_states('core' => false, 'ops' => true)
  end

  it 'allows multi-select with Ctrl for task buttons' do
    click_task_with_modifiers(first: 'core', second: 'ops', modifier: Qt::ControlModifier)
    expect_button_check_states('core' => true, 'ops' => true)
  end

  it 'selects task range with Shift from last anchor' do
    click_task_with_modifiers(first: 'core', second: 'qa', modifier: Qt::ShiftModifier, tasks: %w[core ops qa ux])
    expect_button_check_states('core' => true, 'ops' => true, 'qa' => true, 'ux' => false)
  end

  it 'keeps full long task text and tooltip in sidebar buttons' do
    task_button = render_single_long_task
    expect(task_button.tool_tip.to_s).to eq(task_button.text.to_s)
  end

  it 'keeps current task/project inputs unchanged on sidebar project click while running' do
    stub_running_sidebar_project_state
    click_project_while_running('internal')
    expect(view_model).to have_received(:select_projects)
      .with(['internal'], primary_project: 'internal', sync_current_fields: false)
  end

  it 'keeps current task/project inputs unchanged on sidebar task click while running' do
    stub_running_sidebar_task_state
    expect_task_click_while_running_to_preserve_inputs('ops')
  end

  it 'locks task/project inputs when tracking is running' do
    allow(view_model).to receive(:running_current_sheet?).and_return(true)
    main_window.send(:render!)
    expect(read_only_input_values).to eq([true, true])
  end

  private

  def render_and_click(text)
    main_window.send(:render!)
    button_with_text(text).click
  end

  def render_and_click_project(text)
    main_window.send(:render!)
    button_with_text(text).click
    expect(view_model).to have_received(:current_project_name=).with(text)
  end

  def expect_dark_theme_applied
    expect(theme_button.text.to_s).to eq('THEME: DARK')
    expect(qt_window.style_sheet.to_s).to include('#0f172a')
    expect(settings_store).to have_received(:write_theme_name).with('dark')
  end

  def project_input
    find_widget(qt_window, 'project_input')
  end

  def task_input
    find_widget(qt_window, 'task_input')
  end

  def task_buttons
    widgets_of_type(qt_window, QPushButton).select { |button| button.object_name == 'task_button' }
  end

  def archive_toggle
    find_widget(qt_window, 'sidebar_archive_toggle')
  end

  def archive_toggle_checked?
    archive_toggle&.is_checked
  end

  def expect_button_check_states(states)
    states.each do |text, checked|
      expect(button_with_text(text).is_checked).to be(checked)
    end
  end

  def current_input_values
    [task_input.text.to_s, project_input.text.to_s]
  end

  def expect_current_inputs(task_value, project_value)
    expect(task_input.text.to_s).to eq(task_value)
    expect(project_input.text.to_s).to eq(project_value)
  end

  def render_with_acme_project_input
    stub_sidebar_project_state(
      selected_project: 'acme',
      selected_projects: ['acme'],
      project_names: ['* ALL', 'acme'],
      current_project_name: 'acme'
    )
    main_window.send(:render!, sync_sheet: true)
  end

  def rerender_with_blank_project_name
    allow(view_model).to receive(:current_project_name).and_return('')
    main_window.send(:render!, sync_sheet: true)
  end

  def render_single_select_tasks(tasks)
    allow(view_model).to receive_messages(selected_project: 'acme', task_names_for_selected_project: tasks)
    allow(QApplication).to receive(:keyboard_modifiers).and_return(0)
    main_window.send(:render!)
  end

  def render_task_shortcuts(tasks)
    allow(view_model).to receive_messages(selected_project: 'acme', task_names_for_selected_project: tasks)
    main_window.send(:render!)
  end

  def render_without_task_shortcuts
    allow(view_model).to receive_messages(selected_project: '* ALL', task_names_for_selected_project: [])
    main_window.send(:render!)
  end

  def click_task_buttons(*labels)
    labels.each { |label| button_with_text(label).click }
  end

  def click_project_with_modifiers(first:, second:, modifier:, projects: ['* ALL', 'acme', 'internal'])
    stub_sidebar_project_state(project_names: projects)
    allow(QApplication).to receive(:keyboard_modifiers).and_return(0)
    render_and_click(first)
    allow(QApplication).to receive(:keyboard_modifiers).and_return(modifier)
    button_with_text(second).click
  end

  def select_project_range(first, second)
    click_project_with_modifiers(
      first: first,
      second: second,
      modifier: Qt::ShiftModifier,
      projects: ['* ALL', 'acme', 'internal', 'ops']
    )
  end

  def click_task_with_modifiers(first:, second:, modifier:, tasks: %w[core ops qa])
    render_single_select_tasks(tasks)
    button_with_text(first).click
    allow(QApplication).to receive(:keyboard_modifiers).and_return(modifier)
    button_with_text(second).click
  end

  def render_single_long_task
    long_task = 'very-long-task-name-with-details-and-suffix-1234567890'
    allow(view_model).to receive_messages(selected_project: 'acme', task_names_for_selected_project: [long_task])
    main_window.send(:render!)
    task_buttons.first
  end

  def click_project_while_running(project)
    main_window.send(:render!)
    previous_inputs = current_input_values
    button_with_text(project).click
    expect(current_input_values).to eq(previous_inputs)
    expect(view_model).not_to have_received(:current_project_name=).with(project)
  end

  def expect_task_click_while_running_to_preserve_inputs(task)
    main_window.send(:render!)
    previous_inputs = current_input_values
    button_with_text(task).click
    expect_task_click_to_keep_current_inputs(previous_inputs)
    expect_task_selection_without_current_field_update(task)
  end

  def expect_task_click_to_keep_current_inputs(previous_inputs)
    expect(current_input_values).to eq(previous_inputs)
  end

  def expect_task_selection_without_current_field_update(task)
    expect(view_model).to have_received(:select_tasks).with([task])
    expect(view_model).not_to have_received(:current_task_input=).with(task)
  end

  def read_only_input_values
    [task_input.is_read_only, project_input.is_read_only]
  end

  def stub_sidebar_project_state(options = {})
    values = {
      selected_project: '* ALL',
      selected_projects: ['* ALL'],
      project_names: ['* ALL', 'acme'],
      running_current_sheet?: false
    }.merge(options)
    allow(view_model).to receive_messages(values)
    allow(view_model).to receive(:select_projects) do |new_projects, primary_project:, **|
      allow(view_model).to receive_messages(selected_projects: new_projects, selected_project: primary_project)
    end
  end

  def stub_running_sidebar_project_state
    stub_sidebar_project_state(
      project_names: ['* ALL', 'acme', 'internal'],
      current_sheet_input: 'running-task',
      current_project_name: 'running-project',
      running_current_sheet?: true
    )
  end

  def stub_running_sidebar_task_state
    stub_sidebar_project_state(
      selected_project: 'acme',
      selected_projects: ['acme'],
      project_names: ['* ALL', 'acme'],
      current_sheet_input: 'running-task',
      current_project_name: 'running-project',
      task_names_for_selected_project: %w[core ops],
      running_current_sheet?: true
    )
  end
end
