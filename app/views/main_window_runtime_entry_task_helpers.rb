# frozen_string_literal: true

module QTimetrap
  module Views
    # Entry task move handlers for MainWindow runtime.
    module MainWindowRuntimeEntryTaskHelpers
      private

      def handle_entry_task_changed(entry_id, task_name)
        view_model.update_entry_task(entry_id, task_name)
        @pending_refresh = true
      rescue StandardError => e
        warn("[qtimetrap] update task failed: #{e.class}: #{e.message}")
      end

      def task_suggestions_for_project(project_name)
        view_model.task_names_for_project(project_name)
      end
    end
  end
end
