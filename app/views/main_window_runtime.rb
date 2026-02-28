# frozen_string_literal: true

module QTimetrap
  module Views
    # Event/runtime behavior extracted from MainWindow.
    module MainWindowRuntime
      private

      def on_tick
        return if window.is_visible.zero?
        return close if shutdown_requested?

        now = Time.now
        update_live_indicators(now)
        refresh_if_needed
      end

      def update_live_indicators(now)
        controls.clock_label.set_text(now.strftime('%a %d %b %Y  %H:%M:%S'))
        controls.timer_label.set_text(view_model.running_timer_line(now: now))
        controls.update_project_label(view_model.current_sheet_label(now: now))
      end

      def refresh_if_needed
        return unless pending_refresh?

        view_model.refresh!
        render!(sync_sheet: true)
        @pending_refresh = false
      end

      def render!(sync_sheet: false)
        selected_project = view_model.selected_project
        render_sidebar(selected_project)
        render_controls(sync_sheet: sync_sheet)
        entries.render(view_model.entry_nodes)
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

      def render_sidebar(selected_project)
        sidebar.render(projects: view_model.project_names, selected_project: selected_project)
      end

      def render_controls(sync_sheet:)
        controls.update_summary(view_model.summary_line)
        sync_task_input(sync_sheet)
        update_action_button
        update_sheet_label
        controls.update_theme_label(theme.name)
      end

      def sync_task_input(sync_sheet)
        controls.update_task_input(view_model.current_sheet_input) if sync_sheet
      end

      def update_action_button
        controls.update_action_button(running: view_model.running_current_sheet?)
      end

      def update_sheet_label
        controls.update_project_label(view_model.current_sheet_label)
      end

      def switch_theme!
        @theme = theme.with_name(next_theme_name)
        apply_theme
        render!
      rescue StandardError => e
        warn("[qtimetrap] save theme failed: #{e.class}: #{e.message}")
      end

      def on_key_press(event)
        key = extract_event_value(event, :a) || 0
        modifiers = extract_event_value(event, :b) || 0
        ctrl_mask = self.class::CTRL_MODIFIER
        quit_key = self.class::KEY_Q
        request_shutdown if modifiers.anybits?(ctrl_mask) && key == quit_key
      end

      def pending_refresh?
        @pending_refresh
      end

      def shutdown_requested?
        @shutdown_requested
      end
    end
  end
end
