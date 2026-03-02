# frozen_string_literal: true

module QTimetrap
  module Views
    # Event/runtime behavior extracted from MainWindow.
    module MainWindowRuntime
      include MainWindowRuntimeEntryTimeHelpers

      private

      def on_tick
        return unless window.is_visible
        return close if @shutdown_requested

        now = Time.now
        update_live_indicators(now)
        refresh_if_needed
      end

      def update_live_indicators(now)
        controls.clock_label.set_text(now.strftime('%a %d %b %Y  %H:%M:%S'))
        controls.timer_label.set_text(view_model.running_timer_line(now: now))
      end

      def refresh_if_needed
        return unless @pending_refresh

        view_model.refresh!
        render!(sync_sheet: true)
        @pending_refresh = false
      end

      def render!(sync_sheet: false)
        selected_project = view_model.selected_project
        sidebar.render(
          projects: view_model.project_names,
          selected_project: selected_project,
          tasks: view_model.task_names_for_selected_project,
          selected_task: view_model.selected_tasks.first
        )
        render_controls(sync_sheet: sync_sheet)
        entries.render(view_model.entry_nodes)
      end

      def handle_start(task_input, project_name)
        task_name = resolved_start_task(task_input)
        project = resolved_start_project(project_name)
        view_model.current_project_name = project
        view_model.current_task_input = task_name
        view_model.start_tracking(view_model.sheet_for_task_input(task_name))
        @pending_refresh = true
      rescue StandardError => e
        warn("[qtimetrap] start failed: #{e.class}: #{e.message}")
      end

      def handle_stop
        view_model.stop_tracking
        @pending_refresh = true
      rescue StandardError => e
        warn("[qtimetrap] stop failed: #{e.class}: #{e.message}")
      end

      def handle_project_selected(project)
        view_model.select_project(project)
        view_model.current_project_name = project unless project == '* ALL'
        render!
        controls.update_task_input(view_model.current_sheet_input)
        controls.update_project_input(project == '* ALL' ? '' : project)
      end

      def handle_task_selected(tasks, task)
        view_model.select_tasks(tasks)
        view_model.current_task_input = task.to_s
        controls.update_task_input(view_model.current_sheet_input)
        render_controls(sync_sheet: false)
        entries.render(view_model.entry_nodes)
      end

      def handle_project_input(project_name)
        view_model.current_project_name = project_name
      end

      def handle_entry_note_changed(entry_id, note)
        view_model.update_entry_note(entry_id, note)
      rescue StandardError => e
        warn("[qtimetrap] update note failed: #{e.class}: #{e.message}")
      end

      def resolved_start_task(fallback_task)
        value = controls.task_input.text.to_s.strip
        return value unless value.empty?

        fallback_task.to_s.strip
      end

      def resolved_start_project(fallback)
        value = controls.project_input.text.to_s.strip
        return value unless value.empty?

        fallback.to_s.strip
      end

      def render_controls(sync_sheet:)
        controls.update_summary(view_model.summary_line)
        update_tracking_controls(sync_sheet: sync_sheet)
        controls.update_theme_label(theme.name)
      end

      def update_tracking_controls(sync_sheet:)
        controls.update_task_input(view_model.current_sheet_input) if sync_sheet
        controls.update_action_button(running: view_model.running_current_sheet?)
        project_name = view_model.current_project_name.to_s
        controls.update_project_input(project_name) unless project_name.strip.empty?
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
        ctrl_mask = Qt::ControlModifier
        quit_key = Qt::Key_Q
        request_shutdown if modifiers.anybits?(ctrl_mask) && key == quit_key
      end
    end
  end
end
