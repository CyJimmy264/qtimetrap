# frozen_string_literal: true

require 'spec_helper'

RSpec.describe QTimetrap::Views::MainWindow do
  include_context :main_window_qt_boot
  include_context :main_window_setup
  include_context :main_window_cleanup

  it 'builds a Qt widget window' do
    expect(window_identity).to eq([QWidget, 'QTimetrap'])
  end

  it 'adapts control widths when window is resized' do
    expect(resized_content_widths).to all(be >= 0)
  end

  it 'builds layout with resizable sidebar splitter' do
    splitter = widgets_of_type(qt_window, QSplitter).first
    sidebar_panel = find_widget(qt_window, 'sidebar_panel')
    expect_resizable_sidebar_layout(splitter, sidebar_panel)
  end

  it 'applies fitted timer font size on startup' do
    timer_label = find_widget(qt_window, 'timer_label')
    expect(timer_label.style_sheet.to_s).to include('font-size:')
  end

  it 'collapses and expands sidebar from splitter toggle button' do
    expect(sidebar_visibility_cycle).to eq([true, false, true])
  end

  private

  def toggle_sidebar(button)
    button.show
    button.click
    QApplication.process_events
  end

  def window_identity
    [qt_window.class, qt_window.window_title]
  end

  def resized_content_widths
    controls_widget, entries_widget = tracked_content_widgets
    widths_before = widget_widths(controls_widget, entries_widget)
    qt_window.resize(1700, 980)
    QApplication.process_events
    widget_width_deltas(controls_widget, entries_widget, widths_before)
  end

  def tracked_content_widgets
    [main_window.send(:controls).widget, main_window.send(:entries).widget]
  end

  def widget_widths(*widgets)
    widgets.map(&:width)
  end

  def widget_width_deltas(controls_widget, entries_widget, widths_before)
    current_widths = widget_widths(controls_widget, entries_widget)
    current_widths.zip(widths_before).map { |current, previous| current - previous }
  end

  def expect_resizable_sidebar_layout(splitter, sidebar_panel)
    expect(splitter).not_to be_nil
    expect(sidebar_panel).not_to be_nil
    expect(sidebar_panel.minimum_width).to eq(180)
    expect(sidebar_panel.maximum_width).to eq(520)
  end

  def expect_sidebar_toggle_cycle(button, sidebar_panel)
    expect(button).not_to be_nil
    expect(sidebar_panel.is_visible).to be(true)
    expect_sidebar_hidden_after_toggle(button, sidebar_panel)
    expect_sidebar_visible_after_toggle(button, sidebar_panel)
  end

  def expect_sidebar_hidden_after_toggle(button, sidebar_panel)
    toggle_sidebar(button)
    expect(sidebar_panel.is_visible).to be(false)
  end

  def expect_sidebar_visible_after_toggle(button, sidebar_panel)
    toggle_sidebar(button)
    expect(sidebar_panel.is_visible).to be(true)
  end

  def sidebar_visibility_cycle
    main_window.show
    QApplication.process_events
    sidebar_panel = find_widget(qt_window, 'sidebar_panel')
    toggle_button = find_widget(qt_window, 'sidebar_toggle_button')
    visible_before = sidebar_panel.is_visible
    toggle_sidebar(toggle_button)
    hidden_after_toggle = sidebar_panel.is_visible
    toggle_sidebar(toggle_button)
    [visible_before, hidden_after_toggle, sidebar_panel.is_visible]
  end
end
