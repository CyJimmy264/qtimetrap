# frozen_string_literal: true

module QTimetrap
  module Entries
    # State transitions for entry task display/editor widgets.
    module LeafTaskEditorStateHelpers
      private

      def activate_entry_task_input(task_container)
        close_previous_task_editor(task_container)
        show_entry_task_editor(task_container)
        self.active_task_container = task_container
        editor = entry_task_editor(task_container)
        editor_input = entry_task_editor_line_edit(editor)
        editor_input.read_only = false
        editor.set_focus
        editor_input.set_focus
        editor.show_popup
      end

      def deactivate_entry_task_input(task_container)
        editor = entry_task_editor(task_container)
        editor_input = entry_task_editor_line_edit(editor)
        editor_input.read_only = true
        editor.hide_popup
        editor.clear_focus
        show_entry_task_display(task_container)
      end

      def handle_entry_task_focus_out(task_container)
        return unless task_container

        reset_entry_task_editor(task_container)
        deactivate_entry_task_input(task_container)
        return unless active_task_container
        return unless task_container_matches?(active_task_container, task_container)

        self.active_task_container = nil
      end

      def close_previous_task_editor(task_container)
        return unless active_task_container
        return if task_container_matches?(active_task_container, task_container)

        handle_entry_task_focus_out(active_task_container)
      end

      def reset_entry_task_editor(task_container)
        entry_task_editor(task_container).current_text = entry_task_display_input(task_container).text.to_s
      end

      def show_entry_task_editor(task_container)
        entry_task_display_input(task_container).hide
        entry_task_editor(task_container).show
      end

      def show_entry_task_display(task_container)
        entry_task_editor(task_container).hide
        entry_task_display_input(task_container).show
      end

      def sync_entry_task_display(task_container, task_name)
        sync_task_display_field(entry_task_display_input(task_container), task_name)
        entry_task_editor(task_container).current_text = task_name
        entry_task_editor(task_container).tool_tip = task_name
      end
    end
  end
end
