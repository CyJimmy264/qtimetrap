# frozen_string_literal: true

require 'spec_helper'

RSpec.describe QTimetrap::Views::MainWindow do
  include_context :main_window_qt_boot
  include_context :main_window_setup
  include_context :main_window_cleanup

  it 'sends start action with task input text' do
    task_input = find_widget(qt_window, 'task_input')
    project_input = find_widget(qt_window, 'project_input')
    task_input.text = 'focus task'
    project_input.text = 'my-custom-project'
    button_with_text('START').click

    expect(view_model).to have_received(:current_project_name=).with('my-custom-project')
    expect(view_model).to have_received(:current_task_input=).with('focus task')
    expect(view_model).to have_received(:start_tracking).with('acme|focus task')
  end

  it 'sends stop action on stop click' do
    allow(view_model).to receive(:running_current_sheet?).and_return(true)
    main_window.send(:render!)
    button_with_text('STOP').click
    expect(view_model).to have_received(:stop_tracking)
  end

  it 'requests shutdown on Ctrl+Q key event' do
    main_window.send(:on_key_press, { a: Qt::Key_Q, b: Qt::ControlModifier })
    expect(main_window.instance_variable_get(:@shutdown_requested)).to eq(true)
  end

  it 'toggles start action on Space when no active line edit' do
    task_input = find_widget(qt_window, 'task_input')
    project_input = find_widget(qt_window, 'project_input')
    task_input.text = 'space task'
    project_input.text = 'space project'

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
    main_window.show
    QApplication.process_events
    task_input = find_widget(qt_window, 'task_input')
    task_input.set_focus
    allow(qt_window).to receive(:focus_widget).and_return(task_input)
    QApplication.process_events

    main_window.send(:on_space_shortcut)

    expect(view_model).not_to have_received(:start_tracking)
    expect(view_model).not_to have_received(:stop_tracking)
  end

  it 'routes Space to start/stop even when archive toggle has focus' do
    archive_toggle = find_widget(qt_window, 'sidebar_archive_toggle')
    allow(qt_window).to receive(:focus_widget).and_return(archive_toggle)

    main_window.send(:on_space_shortcut)

    expect(view_model).to have_received(:start_tracking)
    expect(view_model).not_to have_received(:archive_mode=)
  end

  it 'does not auto-focus task input on startup' do
    main_window.show
    QApplication.process_events
    task_input = find_widget(qt_window, 'task_input')

    expect(qt_window.focus_widget).not_to eq(task_input)
  end

  it 'binds space shortcut on startup and routes activated to on_space_shortcut' do
    captured_handler = nil
    shortcut = instance_double(QShortcut)
    allow(shortcut).to receive(:connect) do |signal, &block|
      captured_handler = block if signal == 'activated'
    end
    allow(QShortcut).to receive(:new).and_return(shortcut)

    window = described_class.new(view_model: view_model, settings_store: settings_store)
    expect(QShortcut).to have_received(:new).with(kind_of(QKeySequence), kind_of(QWidget))
    expect(captured_handler).not_to be_nil
    allow(window).to receive(:on_space_shortcut)

    captured_handler.call(nil)
    expect(window).to have_received(:on_space_shortcut)
  ensure
    window&.send(:heartbeat)&.stop
    window&.send(:window)&.close
  end
end
