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
end
