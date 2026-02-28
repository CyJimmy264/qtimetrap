# frozen_string_literal: true

module QTimetrap
  module Views
    class MainWindow
      WINDOW_W = 1380
      WINDOW_H = 860
      SIDEBAR_W = 220
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
        @window = QWidget.new do |widget|
          widget.set_window_title('QTimetrap')
          set_name(widget, 'main_window')
          widget.set_geometry(40, 40, WINDOW_W, WINDOW_H)
        end
        set_window_icon
        window.set_style_sheet(theme.application_stylesheet)

        root_layout = QHBoxLayout.new(window)
        root_layout.set_contents_margins(0, 0, 0, 0)
        root_layout.set_spacing(0)

        @sidebar = Components::ProjectSidebarComponent.new(
          parent: window,
          on_project_selected: method(:handle_project_selected)
        )
        sidebar.widget.set_fixed_width(SIDEBAR_W)
        root_layout.add_widget(sidebar.widget)

        content = QWidget.new(window)
        content_layout = QVBoxLayout.new(content)
        content_layout.set_contents_margins(14, 8, 14, 8)
        content_layout.set_spacing(10)

        @controls = Components::TrackerControlsComponent.new(
          parent: content,
          on_start: method(:handle_start),
          on_stop: method(:handle_stop),
          on_refresh: method(:request_refresh),
          on_switch_theme: method(:switch_theme!)
        )
        content_layout.add_widget(controls.widget)

        @entries = Components::EntriesListComponent.new(parent: content)
        content_layout.add_widget(entries.widget)
        content_layout.set_stretch(1, 1)

        root_layout.add_widget(content)
        root_layout.set_stretch(1, 1)
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

      def on_tick
        return if window.is_visible.zero?
        return close if shutdown_requested?

        now = Time.now
        controls.clock_label.set_text(now.strftime('%a %d %b %Y  %H:%M:%S'))
        controls.timer_label.set_text(view_model.running_timer_line(now: now))

        refresh_if_needed
      end

      def refresh_if_needed
        return unless pending_refresh?

        view_model.refresh!
        render!
        @pending_refresh = false
      end

      def render!
        sidebar.render(projects: view_model.project_names, selected_project: view_model.selected_project)
        controls.update_summary(view_model.summary_line)
        controls.update_project_label(view_model.selected_project)
        controls.update_theme_label(theme.name)
        entries.render(view_model.grouped_lines)
      end

      def handle_start(note)
        view_model.start_tracking(note)
        request_refresh
      rescue StandardError => e
        warn("[qtimetrap] start failed: #{e.class}: #{e.message}")
      end

      def handle_stop
        view_model.stop_tracking
        request_refresh
      rescue StandardError => e
        warn("[qtimetrap] stop failed: #{e.class}: #{e.message}")
      end

      def handle_project_selected(project)
        view_model.select_project(project)
        render!
      end

      def request_refresh
        @pending_refresh = true
      end

      def switch_theme!
        @theme = theme.with_name(next_theme_name)
        Application.configuration.theme_name = theme.name
        window.set_style_sheet(theme.application_stylesheet)
        settings_store.write_theme_name(theme.name)
        render!
      rescue StandardError => e
        warn("[qtimetrap] save theme failed: #{e.class}: #{e.message}")
      end

      def on_key_press(event)
        key = extract_event_value(event, :a) || 0
        modifiers = extract_event_value(event, :b) || 0
        ctrl_pressed = modifiers.anybits?(CTRL_MODIFIER)
        request_shutdown if ctrl_pressed && key == KEY_Q
      end

      def pending_refresh?
        @pending_refresh
      end

      def shutdown_requested?
        @shutdown_requested
      end

      def next_theme_name
        current = THEMES.index(theme.name) || 0
        THEMES[(current + 1) % THEMES.length]
      end

      def set_name(widget, value)
        if widget.respond_to?(:set_object_name)
          widget.set_object_name(value)
        elsif widget.respond_to?(:setObjectName)
          widget.setObjectName(value)
        end
      end

      def set_window_icon
        return unless window.respond_to?(:set_window_icon) || window.respond_to?(:setWindowIcon)

        icons_dir = File.join(Application.root, 'app', 'assets', 'icons')
        svg_path = File.join(icons_dir, 'qtimetrap-icon.svg')
        png_fallback = File.join(icons_dir, 'qtimetrap-icon-256.png')
        candidates = [svg_path, png_fallback].select { |path| File.exist?(path) }
        return if candidates.empty?

        icon = QIcon.new(candidates.first)
        candidates.drop(1).each { |path| icon.add_file(path) } if icon.respond_to?(:add_file)
        if window.respond_to?(:set_window_icon)
          window.set_window_icon(icon)
        else
          window.setWindowIcon(icon)
        end
      rescue StandardError => e
        warn("[qtimetrap] icon load failed: #{e.class}: #{e.message}")
      end

      def extract_event_value(event, key)
        return unless event.respond_to?(:[])

        value = event[key]
        return value.to_i if value

        nil
      end
    end
  end
end
