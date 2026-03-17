# frozen_string_literal: true

module QTimetrap
  module Entries
    # Display-field helpers for entry task controls.
    module LeafTaskDisplayHelpers
      private

      def reset_task_display_viewport(task_input)
        task_input.cursor_position = 0
      end

      def sync_task_display_field(task_input, task_name)
        task_input.text = task_name
        task_input.tool_tip = task_name
        reset_task_display_viewport(task_input)
      end
    end
  end
end
