# frozen_string_literal: true

require 'spec_helper'

RSpec.describe QTimetrap::Views::MainWindow do
  include_context :qt

  let(:view_model) do
    instance_double(
      QTimetrap::ViewModels::MainViewModel,
      refresh!: nil,
      project_names: ['* ALL', 'acme'],
      selected_project: 'acme',
      summary_line: 'Week total: 00:10:00 | Total: 02:00:00',
      grouped_lines: [
        'Fri, Feb 28  Total: 01:00:00',
        '  acme | core (1) 01:00:00',
        '    10:00 - 11:00  01:00:00  test'
      ],
      running_timer_line: '00:00:05',
      start_tracking: nil,
      stop_tracking: nil,
      select_project: nil
    )
  end

  let(:settings_store) { instance_double(QTimetrap::Services::SettingsStore, write_theme_name: nil) }
  let(:main_window) { described_class.new(view_model: view_model, settings_store: settings_store) }
  let(:qt_window) { main_window.send(:window) }

  after do
    main_window.send(:heartbeat).stop
    qt_window.dispose if qt_window.respond_to?(:dispose)
  end

  it 'builds a Qt widget window' do
    expect(qt_window).to be_a(QWidget)
    expect(qt_window.window_title).to eq('QTimetrap')
  end

  it 'renders summary, project and entries from view model' do
    main_window.send(:render!)

    expect(qt_window).to have_child_with_text('Week total: 00:10:00 | Total: 02:00:00')
    expect(qt_window).to have_child_with_text('Project: acme')
    expect(qt_window).to have_child_with_text('Fri, Feb 28  Total: 01:00:00')
    expect(qt_window).to have_child_with_text('  acme | core (1) 01:00:00')
  end

  it 'sends start action with task input text' do
    input = widgets_of_type(qt_window, QLineEdit).first
    start_button = button_with_text('START')

    input.text = 'focus task'
    start_button.click

    expect(view_model).to have_received(:start_tracking).with('focus task')
  end

  it 'sends stop action on stop click' do
    stop_button = button_with_text('STOP')

    stop_button.click

    expect(view_model).to have_received(:stop_tracking)
  end


  it 'switches theme at runtime from toolbar button' do
    main_window.send(:render!)
    expect(theme_button.text.to_s).to eq('THEME: LIGHT')

    theme_button.click

    expect(theme_button.text.to_s).to eq('THEME: DARK')
    expect(qt_window.style_sheet.to_s).to include('#0f172a')
    expect(settings_store).to have_received(:write_theme_name).with('dark')
  end

  it 'updates selected project on sidebar project click' do
    main_window.send(:render!)
    project_button = button_with_text('acme')

    project_button.click

    expect(view_model).to have_received(:select_project).with('acme')
  end

  it 'requests shutdown on Ctrl+Q key event' do
    main_window.send(:on_key_press, { a: 0x51, b: 0x04000000 })

    expect(main_window.send(:shutdown_requested?)).to eq(true)
  end


  def theme_button
    widgets_of_type(qt_window, QPushButton).find { |button| button.text.to_s.start_with?('THEME:') }
  end

  def widgets_of_type(root, klass)
    ([root] + widget_descendants(root)).select { |widget| widget.is_a?(klass) }
  end

  def button_with_text(text)
    widgets_of_type(qt_window, QPushButton).find { |button| button.text.to_s == text }
  end
end
