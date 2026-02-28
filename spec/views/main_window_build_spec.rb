# frozen_string_literal: true

require 'spec_helper'

RSpec.describe QTimetrap::Views::MainWindow do
  include_context :main_window_setup
  include_context :main_window_cleanup

  it 'builds a Qt widget window' do
    expect(qt_window).to be_a(QWidget)
    expect(qt_window.window_title).to eq('QTimetrap')
  end

  it 'adapts control widths when window is resized' do
    controls_widget = main_window.send(:controls).widget
    entries_widget = main_window.send(:entries).widget
    before_controls_width = controls_widget.width
    before_entries_width = entries_widget.width
    qt_window.resize(1700, 980)
    QApplication.process_events
    expect(controls_widget.width).to be >= before_controls_width
    expect(entries_widget.width).to be >= before_entries_width
  end
end
