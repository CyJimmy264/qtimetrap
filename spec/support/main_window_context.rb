# frozen_string_literal: true

module MainWindowHelpers
  def widgets_of_type(root, klass)
    ([root] + widget_descendants(root)).grep(klass)
  end

  def button_with_text(text)
    widgets_of_type(qt_window, QPushButton).find { |button| button.text.to_s == text }
  end

  def theme_button
    widgets_of_type(qt_window, QPushButton).find { |button| button.text.to_s.start_with?('THEME:') }
  end
end

RSpec.configure do |config|
  config.include MainWindowHelpers
end

RSpec.shared_context :main_window_setup do
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
  let(:main_window) { QTimetrap::Views::MainWindow.new(view_model: view_model, settings_store: settings_store) }
  let(:qt_window) { main_window.send(:window) }
end

RSpec.shared_context :main_window_cleanup do
  after do
    main_window.send(:heartbeat).stop
    qt_window.close if qt_window.respond_to?(:close)
    QApplication.process_events
    qt_window.dispose if qt_window.respond_to?(:dispose)
  end
end
