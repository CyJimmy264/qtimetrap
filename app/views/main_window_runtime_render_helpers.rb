# frozen_string_literal: true

module QTimetrap
  module Views
    # Rendering helpers for MainWindow runtime loop and interactions.
    module MainWindowRuntimeRenderHelpers
      private

      def render!(sync_sheet: false)
        render_sidebar
        render_controls(sync_sheet: sync_sheet)
        render_entries_panel
      end

      def render_sidebar
        sidebar.render(
          projects: view_model.project_names,
          tasks: view_model.task_names_for_selected_project,
          selection: {
            selected_project: view_model.selected_project,
            selected_projects: view_model.selected_projects
          },
          selected_task: view_model.selected_tasks.first,
          archive_mode: view_model.archive_mode?
        )
      end

      def render_entries_panel
        entries.update_time_range_inputs(
          from_at: view_model.time_filter_from_at,
          to_at: view_model.time_filter_to_at
        )
        entries.render(view_model.entry_nodes)
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
    end
  end
end
