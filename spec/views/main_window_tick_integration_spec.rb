# frozen_string_literal: true

require 'spec_helper'

RSpec.describe QTimetrap::Views::MainWindow do
  include_context :main_window_qt_boot
  include_context :main_window_setup
  include_context :main_window_cleanup

  it 'skips tick work when window reports not visible' do
    prepare_tick_state(false)
    tick_twice
    expect_tick_to_skip_refresh
  end

  it 'runs tick refresh once when window reports visible' do
    prepare_tick_state(true)
    tick_twice
    expect_tick_to_refresh_once
  end

  private

  def prepare_tick_state(visible)
    main_window.send(:heartbeat).stop
    QApplication.process_events
    allow(view_model).to receive(:refresh!)
    fake_window = instance_double(QWidget, is_visible: visible)
    allow(main_window).to receive(:window).and_return(fake_window)
    main_window.instance_variable_set(:@pending_refresh, true)
  end

  def tick_twice
    main_window.send(:on_tick)
    main_window.send(:on_tick)
  end

  def expect_tick_to_skip_refresh
    expect(view_model).not_to have_received(:refresh!)
    expect(main_window.instance_variable_get(:@pending_refresh)).to be(true)
  end

  def expect_tick_to_refresh_once
    expect(view_model).to have_received(:refresh!).once
    expect(main_window.instance_variable_get(:@pending_refresh)).to be(false)
  end
end
