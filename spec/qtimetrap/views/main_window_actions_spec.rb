# frozen_string_literal: true

require 'spec_helper'

RSpec.describe QTimetrap::Views::MainWindow do
  include_context :main_window_qt_boot
  include_context :main_window_setup
  include_context :main_window_cleanup

  it 'sends start action with task input text' do
    start_tracking_from_inputs(task: 'focus task', project: 'my-custom-project')
    expect_start_action('focus task', 'my-custom-project')
  end

  it 'sends stop action on stop click' do
    allow(view_model).to receive(:running_current_sheet?).and_return(true)
    main_window.send(:render!)
    button_with_text('STOP').click
    expect(view_model).to have_received(:stop_tracking)
  end

  it 'requests shutdown on Ctrl+Q key event' do
    main_window.send(:on_key_press, { a: Qt::Key_Q, b: Qt::ControlModifier })
    expect(main_window.instance_variable_get(:@shutdown_requested)).to be(true)
  end

  it 'toggles start action on Space when no active line edit' do
    fill_current_inputs(task: 'space task', project: 'space project')

    main_window.send(:on_space_shortcut)

    expect(view_model).to have_received(:start_tracking).with('acme|space task')
  end

  it 'toggles stop action on Space when running' do
    allow(view_model).to receive(:running_current_sheet?).and_return(true)
    main_window.send(:render!)

    main_window.send(:on_space_shortcut)

    expect(view_model).to have_received(:stop_tracking)
  end

  it 'does not toggle start/stop on Space when editable line edit is focused' do
    focus_task_input
    main_window.send(:on_space_shortcut)
    expect_space_shortcut_to_be_ignored
  end

  it 'routes Space to start/stop even when archive toggle has focus' do
    focus_archive_toggle
    main_window.send(:on_space_shortcut)
    expect_space_shortcut_to_start_without_toggling_archive
  end

  it 'clears editable line edit focus on click outside inputs' do
    focus_task_input
    allow(qt_window).to receive(:child_at).with(12, 18).and_return(button_with_text('START'))

    main_window.send(:on_mouse_button_press, { a: 12, b: 18 }, source_widget: qt_window)

    expect(task_input).to have_received(:clear_focus)
  end

  it 'keeps editable line edit focus on click inside another editable input' do
    focus_task_input
    allow(qt_window).to receive(:child_at).with(24, 30).and_return(project_input)

    main_window.send(:on_mouse_button_press, { a: 24, b: 30 }, source_widget: qt_window)

    expect(task_input).not_to have_received(:clear_focus)
  end

  it 'clears editable line edit focus on click in empty sidebar area' do
    focus_task_input
    allow(sidebar_panel).to receive(:child_at).with(30, 220).and_return(nil)

    main_window.send(:on_mouse_button_press, { a: 30, b: 220 }, source_widget: sidebar_panel)

    expect(task_input).to have_received(:clear_focus)
  end

  it 'does not auto-focus task input on startup' do
    main_window.show
    QApplication.process_events
    task_input = find_widget(qt_window, 'task_input')

    expect(qt_window.focus_widget).not_to eq(task_input)
  end

  it 'binds space shortcut on startup and routes activated to on_space_shortcut' do
    window = expect_startup_space_shortcut_binding
  ensure
    window&.send(:heartbeat)&.stop
    window&.send(:window)&.close
  end

  private

  def build_window_with_captured_shortcut
    captured_handler = nil
    shortcut = instance_double(QShortcut)
    allow(shortcut).to receive(:connect) do |signal, &block|
      captured_handler = block if signal == 'activated'
    end
    allow(QShortcut).to receive(:new).and_return(shortcut)
    [described_class.new(view_model: view_model, settings_store: settings_store), captured_handler]
  end

  def expect_shortcut_binding(captured_handler)
    expect(QShortcut).to have_received(:new).with(kind_of(QKeySequence), kind_of(QWidget))
    expect(captured_handler).not_to be_nil
  end

  def trigger_space_shortcut(window, captured_handler)
    allow(window).to receive(:on_space_shortcut)
    captured_handler.call(nil)
  end

  def expect_space_shortcut_trigger(window, captured_handler)
    trigger_space_shortcut(window, captured_handler)
    expect(window).to have_received(:on_space_shortcut)
  end

  def expect_startup_space_shortcut_binding
    window, captured_handler = build_window_with_captured_shortcut
    expect_shortcut_binding(captured_handler)
    expect_space_shortcut_trigger(window, captured_handler)
    window
  end

  def start_tracking_from_inputs(task:, project:)
    fill_current_inputs(task: task, project: project)
    button_with_text('START').click
  end

  def expect_start_action(task, project)
    expect(view_model).to have_received(:current_project_name=).with(project)
    expect(view_model).to have_received(:current_task_input=).with(task)
    expect(view_model).to have_received(:start_tracking).with("acme|#{task}")
  end

  def fill_current_inputs(task:, project:)
    find_widget(qt_window, 'task_input').text = task
    find_widget(qt_window, 'project_input').text = project
  end

  def focus_task_input
    main_window.show
    QApplication.process_events
    task_input = find_widget(qt_window, 'task_input')
    allow(task_input).to receive(:clear_focus).and_call_original
    task_input.set_focus
    allow(qt_window).to receive(:focus_widget).and_return(task_input)
    QApplication.process_events
  end

  def expect_space_shortcut_to_be_ignored
    expect(view_model).not_to have_received(:start_tracking)
    expect(view_model).not_to have_received(:stop_tracking)
  end

  def focus_archive_toggle
    archive_toggle = find_widget(qt_window, 'sidebar_archive_toggle')
    allow(qt_window).to receive(:focus_widget).and_return(archive_toggle)
  end

  def task_input
    find_widget(qt_window, 'task_input')
  end

  def project_input
    find_widget(qt_window, 'project_input')
  end

  def sidebar_panel
    find_widget(qt_window, 'sidebar_panel')
  end

  def expect_space_shortcut_to_start_without_toggling_archive
    expect(view_model).to have_received(:start_tracking)
    expect(view_model).not_to have_received(:archive_mode=)
  end
end
