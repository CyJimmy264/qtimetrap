# frozen_string_literal: true

module QTimetrap
  module Views
    # Event/runtime behavior extracted from MainWindow.
    module MainWindowRuntime
      include MainWindowRuntimeEntryTimeHelpers
      include MainWindowRuntimeKeyHelpers
      include MainWindowRuntimeRenderHelpers

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
        update_current_fields = !view_model.running_current_sheet?
        view_model.select_project(project, sync_current_fields: update_current_fields)
        view_model.current_project_name = project if update_current_fields && project != '* ALL'
        render!
        return unless update_current_fields

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

      def handle_archive_mode_toggled(enabled)
        view_model.archive_mode = enabled
        render!(sync_sheet: false)
      end

      def handle_project_input(project_name)
        return if view_model.running_current_sheet?

        view_model.current_project_name = project_name
      end

      def handle_time_range_changed(from_at, to_at)
        view_model.update_time_range_filter(from_at: from_at, to_at: to_at)
        render_controls(sync_sheet: false)
        entries.update_time_range_inputs(
          from_at: view_model.time_filter_from_at,
          to_at: view_model.time_filter_to_at
        )
        entries.render(view_model.entry_nodes)
      rescue StandardError => e
        warn("[qtimetrap] update time-range failed: #{e.class}: #{e.message}")
      end

      def handle_entry_note_changed(entry_id, note)
        view_model.update_entry_note(entry_id, note)
      rescue StandardError => e
        warn("[qtimetrap] update note failed: #{e.class}: #{e.message}")
      end

      def handle_entry_archived(entry_id)
        view_model.archive_entry(entry_id)
        @pending_refresh = true
      rescue StandardError => e
        warn("[qtimetrap] archive entry failed: #{e.class}: #{e.message}")
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

      def switch_theme!
        @theme = theme.with_name(next_theme_name)
        apply_theme
        render!
      rescue StandardError => e
        warn("[qtimetrap] save theme failed: #{e.class}: #{e.message}")
      end
    end
  end
end
