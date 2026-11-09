# frozen_string_literal: true

module QTimetrap
  module Views
    # Archive handlers for MainWindow runtime.
    module MainWindowRuntimeArchiveHelpers
      private

      def handle_archive_mode_toggled(enabled)
        view_model.archive_mode = enabled
        sidebar.update_tasks(
          tasks: view_model.task_names_for_selected_project,
          selected_project: view_model.selected_project,
          selected_task: view_model.selected_tasks.first
        )
        controls.update_summary(view_model.summary_line)
        entries.filter_to(view_model.entry_nodes)
      end

      def handle_entry_archived(entry_id)
        archive_mode_active? ? view_model.unarchive_entry(entry_id) : view_model.archive_entry(entry_id)
        @pending_refresh = true
      rescue StandardError => e
        warn("[qtimetrap] archive entry failed: #{e.class}: #{e.message}")
      end

      def archive_mode_active?
        view_model.archive_mode?
      end
    end
  end
end
