# frozen_string_literal: true

require 'spec_helper'

RSpec.describe QTimetrap::Views::MainWindow do
  include_context :main_window_qt_boot
  include_context :main_window_setup
  include_context :main_window_cleanup

  it 'skips tick work when window reports not visible' do
    main_window.send(:heartbeat).stop
    QApplication.process_events
    allow(view_model).to receive(:refresh!)
    fake_window = instance_double(QWidget, is_visible: false)
    allow(main_window).to receive(:window).and_return(fake_window)
    main_window.instance_variable_set(:@pending_refresh, true)

    main_window.send(:on_tick)
    allow(fake_window).to receive(:is_visible).and_return(false)
    main_window.send(:on_tick)

    expect(view_model).not_to have_received(:refresh!)
    expect(main_window.instance_variable_get(:@pending_refresh)).to be(true)
  end

  it 'runs tick refresh once when window reports visible' do
    main_window.send(:heartbeat).stop
    QApplication.process_events
    fake_window = instance_double(QWidget, is_visible: true)
    allow(main_window).to receive(:window).and_return(fake_window)
    allow(view_model).to receive(:refresh!)
    main_window.instance_variable_set(:@pending_refresh, true)

    main_window.send(:on_tick)
    allow(fake_window).to receive(:is_visible).and_return(true)
    main_window.send(:on_tick)

    expect(view_model).to have_received(:refresh!).once
    expect(main_window.instance_variable_get(:@pending_refresh)).to be(false)
  end
end
