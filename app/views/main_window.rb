# frozen_string_literal: true

module QTimetrap
  module Views
    class MainWindow
      WINDOW_W = 1380
      WINDOW_H = 860
      SIDEBAR_W = 220
      TOPBAR_H = 56
      THEMES = %w[light dark].freeze
      HEARTBEAT_MS = 33
      RESIZE_THROTTLE_MS = 90
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
        @last_size = nil
        @pending_size = nil
        @last_relayout_ms = 0
        @shutdown_requested = false

        build_window
        connect_resize_events
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

      attr_reader :view_model, :window, :theme, :settings_store

      def build_window
        @window = QWidget.new do |widget|
          widget.set_window_title('QTimetrap')
          set_name(widget, 'main_window')
          widget.set_geometry(40, 40, WINDOW_W, WINDOW_H)
        end
        set_window_icon
        window.set_style_sheet(theme.application_stylesheet)

        background = QLabel.new(window)
        set_name(background, 'app_background')

        @sidebar = Components::ProjectSidebarComponent.new(
          parent: window,
          x: 0,
          y: 0,
          width: SIDEBAR_W,
          height: WINDOW_H,
          on_project_selected: method(:handle_project_selected)
        )

        @controls = Components::TrackerControlsComponent.new(
          parent: window,
          x: SIDEBAR_W + 14,
          y: TOPBAR_H,
          width: WINDOW_W - (SIDEBAR_W + 14) - 14,
          on_start: method(:handle_start),
          on_stop: method(:handle_stop),
          on_refresh: method(:request_refresh),
          on_switch_theme: method(:switch_theme!)
        )

        @entries = Components::EntriesListComponent.new(
          parent: window,
          x: SIDEBAR_W + 14,
          y: TOPBAR_H + 156,
          width: WINDOW_W - (SIDEBAR_W + 14) - 14,
          height: WINDOW_H - (TOPBAR_H + 170)
        )

        @background = background
        relayout!
      end

      def connect_heartbeat
        @heartbeat = QTimer.new(window)
        heartbeat.set_interval(HEARTBEAT_MS)
        heartbeat.connect('timeout') { |_| on_tick }
        heartbeat.start
      end

      def connect_resize_events
        window.on(:resize) { |event| on_resize(event) }
        window.on(:key_press) { |event| on_key_press(event) }
      end

      def on_tick
        return if window.is_visible.zero?
        return close if shutdown_requested?

        apply_pending_relayout_if_due

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

      def pending_refresh?
        @pending_refresh
      end

      def sidebar
        @sidebar
      end

      def controls
        @controls
      end

      def entries
        @entries
      end

      def heartbeat
        @heartbeat
      end

      def next_theme_name
        current = THEMES.index(theme.name) || 0
        THEMES[(current + 1) % THEMES.length]
      end

      def on_resize(event)
        width = extract_event_size(event, :a) || window.width
        height = extract_event_size(event, :b) || window.height
        @pending_size = [width, height]
        apply_pending_relayout_if_due
      end

      def on_key_press(event)
        key = extract_event_size(event, :a) || 0
        modifiers = extract_event_size(event, :b) || 0
        ctrl_pressed = (modifiers & CTRL_MODIFIER) != 0
        request_shutdown if ctrl_pressed && key == KEY_Q
      end

      def apply_pending_relayout_if_due
        return unless @pending_size

        now_ms = monotonic_ms
        return if (now_ms - @last_relayout_ms) < RESIZE_THROTTLE_MS

        relayout_with_size!(@pending_size)
        @pending_size = nil
        @last_relayout_ms = now_ms
      end

      def relayout!
        relayout_with_size!([window.width, window.height])
      end

      def relayout_with_size!(size)
        width = [size[0], 980].max
        height = [size[1], 640].max
        content_x = SIDEBAR_W + 14
        content_width = [width - content_x - 14, 680].max

        background.set_geometry(0, 0, width, height)
        sidebar.relayout(x: 0, y: 0, width: SIDEBAR_W, height: height)
        controls.relayout(x: content_x, y: TOPBAR_H, width: content_width)
        entries.relayout(
          x: content_x,
          y: TOPBAR_H + 156,
          width: content_width,
          height: [height - (TOPBAR_H + 170), 260].max
        )
        @last_size = size
      end

      def background
        @background
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

      def extract_event_size(event, key)
        return unless event.respond_to?(:[])

        value = event[key]
        return value.to_i if value

        nil
      end

      def monotonic_ms
        (Process.clock_gettime(Process::CLOCK_MONOTONIC) * 1000).to_i
      end

      def shutdown_requested?
        @shutdown_requested
      end
    end
  end
end
