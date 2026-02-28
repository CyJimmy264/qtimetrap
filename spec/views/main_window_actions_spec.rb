# frozen_string_literal: true

require 'spec_helper'

RSpec.describe QTimetrap::Views::MainWindow do
  include_context :main_window_setup
  include_context :main_window_cleanup

  it 'sends start action with task input text' do
    input = widgets_of_type(qt_window, QLineEdit).first
    input.text = 'focus task'
    button_with_text('START').click
    expect(view_model).to have_received(:start_tracking).with('focus task')
  end

  it 'sends stop action on stop click' do
    button_with_text('STOP').click
    expect(view_model).to have_received(:stop_tracking)
  end

  it 'requests shutdown on Ctrl+Q key event' do
    main_window.send(:on_key_press, { a: 0x51, b: 0x04000000 })
    expect(main_window.send(:shutdown_requested?)).to eq(true)
  end
end
