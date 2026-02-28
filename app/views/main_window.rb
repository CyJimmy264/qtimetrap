# frozen_string_literal: true

module QTimetrap
  module Views
    # Main Qt window wiring together components and user interactions.
    class MainWindow
      include MainWindowRuntime
      include MainWindowUiHelpers

      WINDOW_W = 1380
      WINDOW_H = 860
      THEMES = %w[light dark].freeze
      HEARTBEAT_MS = 33
      CTRL_MODIFIER = 0x04000000
      KEY_Q = 0x51

      def initialize(
        view_model: ViewModels::MainViewModel.new,
        theme: Styles::Theme.new(name: 'light', root: Application.root),
        settings_store: Models::NullSettingsStore.new
      )
        @view_model = view_model
        @theme = theme
        @settings_store = settings_store
        @pending_refresh = true
        @shutdown_requested = false

        build_window
        connect_key_events
        connect_heartbeat
      end

      def show
        window.show
      end

      def close
        window.close
      end

      def request_shutdown
        @shutdown_requested = true
      end

      private

      attr_reader :view_model, :window, :theme, :settings_store, :sidebar, :controls, :entries, :heartbeat

      def build_window
        @window = build_base_window
        set_window_icon
        window.set_style_sheet(theme.application_stylesheet)
        ui = MainWindowLayoutBuilder.new(
          window: window,
          callbacks: layout_callbacks
        ).build
        @sidebar = ui.fetch(:sidebar)
        @controls = ui.fetch(:controls)
        @entries = ui.fetch(:entries)
      end

      def connect_heartbeat
        @heartbeat = QTimer.new(window)
        heartbeat.set_interval(HEARTBEAT_MS)
        heartbeat.connect('timeout') { |_| on_tick }
        heartbeat.start
      end

      def connect_key_events
        window.on(:key_press) { |event| on_key_press(event) }
      end

      def layout_callbacks
        {
          on_project_selected: method(:handle_project_selected),
          on_start: method(:handle_start),
          on_stop: method(:handle_stop),
          on_refresh: method(:request_refresh),
          on_switch_theme: method(:switch_theme!)
        }
      end
    end
  end
end
