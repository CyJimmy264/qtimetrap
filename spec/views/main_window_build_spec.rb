# frozen_string_literal: true

require 'spec_helper'

RSpec.describe QTimetrap::Views::MainWindow do
  include_context :main_window_qt_boot
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

  it 'builds layout with resizable sidebar splitter' do
    splitter = widgets_of_type(qt_window, QSplitter).first
    expect(splitter).not_to be_nil

    sidebar_panel = find_widget(qt_window, 'sidebar_panel')
    expect(sidebar_panel).not_to be_nil
    expect(sidebar_panel.minimum_width).to eq(180)
    expect(sidebar_panel.maximum_width).to eq(520)
  end
end
