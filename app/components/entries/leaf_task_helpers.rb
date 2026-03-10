# frozen_string_literal: true

module QTimetrap
  module Entries
    # Entry-leaf helpers for editable task combo-box controls.
    module LeafTaskHelpers
      private

      def build_entry_task_input(row, node)
        QComboBox.new(row).tap do |task_input|
          task_input.set_object_name('entry_node_entry_task')
          task_input.set_editable(true)
          task_input.instance_variable_set(:@qtimetrap_task_line_edit, build_entry_task_line_edit(row))
          task_input.set_line_edit(entry_task_line_edit(task_input))
          task_input.set_placeholder_text('task')
          task_input.set_minimum_width(220)
          populate_entry_task_options(task_input, node)
          bind_entry_task_input_events(task_input, resolve_entry_id(node))
        end
      end

      def build_entry_task_line_edit(row)
        QLineEdit.new(row).tap do |line_edit|
          line_edit.set_object_name('entry_node_entry_task_input')
        end
      end

      def populate_entry_task_options(task_input, node)
        current_task = node.fetch(:task_name, '').to_s
        suggestions = Array(task_suggestions_for_project&.call(node.fetch(:project_name, '').to_s))
        options = ([current_task] + suggestions.map(&:to_s)).reject(&:empty?).uniq
        options.each { |task_name| task_input.add_item(task_name) }
        task_input.set_current_text(current_task)
        deactivate_entry_task_input(task_input)
      end

      def bind_entry_task_input_events(task_input, entry_id)
        input = entry_task_line_edit(task_input)
        input.on(:mouse_button_press) { |_| activate_entry_task_input(task_input) }
        input.on(:key_press) { |event| handle_entry_task_key_press(task_input, entry_id, event) }
        input.connect('returnPressed') { |_| handle_entry_task_commit(task_input, entry_id) }
        input.on(:focus_out) { |_| handle_entry_task_focus_out(task_input) }
        task_input.connect('textActivated') { |_| handle_entry_task_commit(task_input, entry_id, force: true) }
      end

      def activate_entry_task_input(task_input)
        entry_task_line_edit(task_input).set_read_only(false)
        task_input.set_focus
      end

      def deactivate_entry_task_input(task_input)
        entry_task_line_edit(task_input).set_read_only(true)
        task_input.clear_focus
      end

      def handle_entry_task_key_press(task_input, entry_id, event)
        return unless enter_key?(event)

        handle_entry_task_commit(task_input, entry_id)
      end

      def handle_entry_task_commit(task_input, entry_id, force: false)
        return if entry_task_line_edit(task_input).is_read_only && !force

        task_name = task_input.current_text.to_s
        deactivate_entry_task_input(task_input)
        return unless on_entry_task_change

        on_entry_task_change.call(entry_id, task_name)
      end

      def handle_entry_task_focus_out(task_input)
        deactivate_entry_task_input(task_input)
      end

      def entry_task_line_edit(task_input)
        task_input.instance_variable_get(:@qtimetrap_task_line_edit)
      end
    end
  end
end
