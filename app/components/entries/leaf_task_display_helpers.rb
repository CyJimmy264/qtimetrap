# frozen_string_literal: true

module QTimetrap
  module Entries
    # Display-field helpers for entry task controls.
    module LeafTaskDisplayHelpers
      private

      def sync_task_display_field(task_input, task_name)
        task_input.text = task_name
        task_input.tool_tip = task_name
      end
    end
  end
end
