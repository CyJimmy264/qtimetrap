# frozen_string_literal: true

module MainWindowHelpers
  SAMPLE_ENTRY_NODES = [
    {
      id: 'week:2026-02-23',
      type: :week,
      label: 'Week Feb 23 - Mar 1  Total: 01:00:00',
      children: [
        {
          id: 'day:2026-02-28',
          type: :day,
          label: 'Fri, Feb 28  Total: 01:00:00',
          children: [
            {
              id: 'project:2026-02-28:acme:core',
              type: :project,
              label: 'acme | core (1) 01:00:00',
              children: [
                { id: 'entry:1', type: :entry, label: '10:00 - 11:00  01:00:00  test', children: [] }
              ]
            }
          ]
        }
      ]
    }
  ].freeze

  def sample_entry_nodes
    SAMPLE_ENTRY_NODES
  end

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
  let(:entry_nodes) { sample_entry_nodes }
  let(:settings_store) do
    instance_double(
      QTimetrap::Services::SettingsStore,
      write_theme_name: nil,
      read_window_geometry: nil,
      write_window_geometry: nil
    )
  end
  let(:view_model) do
    instance_double(
      QTimetrap::ViewModels::MainViewModel,
      refresh!: nil,
      project_names: ['* ALL', 'acme'],
      selected_project: 'acme',
      summary_line: 'Week total: 00:10:00 | Total: 02:00:00',
      current_sheet_input: 'acme|core',
      running_current_sheet?: false,
      entry_nodes: entry_nodes,
      running_timer_line: '00:00:05',
      start_tracking: nil,
      stop_tracking: nil,
      select_project: nil
    ).tap do |vm|
      allow(vm).to receive(:current_sheet_label).and_return('acme|core')
    end
  end

  let(:main_window) { QTimetrap::Views::MainWindow.new(view_model: view_model, settings_store: settings_store) }
  let(:qt_window) { main_window.send(:window) }
end

RSpec.shared_context :main_window_qt_boot do
  include_context :qt
end

RSpec.shared_context :main_window_cleanup do
  after do
    main_window.send(:heartbeat).stop
    qt_window.close if qt_window.respond_to?(:close)
    QApplication.process_events
  end
end
