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
        connect_shortcuts
        connect_heartbeat
      end

      def show = window.show

      def close
        persist_window_geometry
        window.close
      end

      def request_shutdown = @shutdown_requested = true

      private

      attr_reader :view_model, :window, :theme, :settings_store, :sidebar, :controls, :entries, :heartbeat

      def build_window
        @window = build_base_window
        restore_window_geometry
        set_window_icon
        window.style_sheet = theme.application_stylesheet
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
        heartbeat.interval = HEARTBEAT_MS
        heartbeat.connect('timeout') { |_| on_tick }
        heartbeat.start
      end

      def connect_key_events
        window.on(:key_press) { |event| on_key_press(event) }
        register_blur_click_source(window)
        register_blur_click_source(sidebar.widget)
        register_blur_click_source(entries.widget)
      end

      def connect_shortcuts
        @space_shortcut = QShortcut.new(QKeySequence.new('Space'), window)
        @space_shortcut.connect('activated') { |_| on_space_shortcut }
      end

      def register_blur_click_source(widget)
        widget.on(:mouse_button_press) { |event| on_mouse_button_press(event, source_widget: widget) }
      end

      def restore_window_geometry
        geometry = settings_store.read_window_geometry
        return unless geometry

        window.set_geometry(
          geometry.fetch(:left),
          geometry.fetch(:top),
          geometry.fetch(:width),
          geometry.fetch(:height)
        )
      end

      def persist_window_geometry
        settings_store.write_window_geometry(
          left: window.x,
          top: window.y,
          width: window.width,
          height: window.height
        )
      rescue StandardError => e
        warn("[qtimetrap] save geometry failed: #{e.class}: #{e.message}")
      end

      def layout_callbacks
        {
          on_project_selected: method(:handle_project_selected),
          on_task_selected: method(:handle_task_selected),
          on_archive_mode_toggled: method(:handle_archive_mode_toggled),
          on_start: method(:handle_start),
          on_project_change: method(:handle_project_input),
          on_time_range_change: method(:handle_time_range_changed),
          on_entry_note_change: method(:handle_entry_note_changed),
          on_entry_task_change: method(:handle_entry_task_changed),
          on_entry_time_change: method(:handle_entry_time_changed),
          task_suggestions_for_project: method(:task_suggestions_for_project),
          on_entry_archive: method(:handle_entry_archived),
          on_stop: method(:handle_stop),
          on_refresh: -> { @pending_refresh = true },
          on_switch_theme: method(:switch_theme!)
        }
      end
    end
  end
end
