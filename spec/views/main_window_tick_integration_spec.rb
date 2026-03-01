# frozen_string_literal: true

require 'spec_helper'

RSpec.describe QTimetrap::Views::MainWindow do
  include_context :main_window_qt_boot
  include_context :main_window_setup
  include_context :main_window_cleanup

  it 'skips tick work when window reports not visible as boolean or integer' do
    allow(qt_window).to receive(:is_visible).and_return(false, 0)
    allow(view_model).to receive(:refresh!)

    main_window.send(:on_tick)
    main_window.send(:on_tick)

    expect(view_model).not_to have_received(:refresh!)
  end

  it 'runs tick refresh once when window reports visible as boolean or integer' do
    allow(qt_window).to receive(:is_visible).and_return(true, 1)
    allow(view_model).to receive(:refresh!)

    main_window.send(:on_tick)
    main_window.send(:on_tick)

    expect(view_model).to have_received(:refresh!).once
  end
end
