# frozen_string_literal: true

module QTimetrap
  module Entries
    # Public helpers for active task editor lifecycle.
    module ListTaskEditorHelpers
      def close_active_task_editor
        return unless active_task_container

        handle_entry_task_focus_out(active_task_container)
      end

      def task_editor_widget?(widget)
        return false unless widget

        task_editor_widget_names.include?(widget.object_name)
      end

      private

      def task_editor_widget_names
        %w[
          entry_node_entry_task_container
          entry_node_entry_task
          entry_node_entry_task_editor
          entry_node_entry_task_editor_input
        ]
      end
    end
  end
end
