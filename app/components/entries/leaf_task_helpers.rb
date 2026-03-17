# frozen_string_literal: true

module QTimetrap
  module Entries
    # Entry-leaf helpers for editable task controls.
    module LeafTaskHelpers
      private

      def build_entry_task_input(row, node)
        task_name = node.fetch(:task_name, '').to_s
        QWidget.new(row).tap do |task_container|
          initialize_entry_task_container(task_container, task_name, node)
          bind_entry_task_input_events(task_container, resolve_entry_id(node))
          show_entry_task_display(task_container)
        end
      end

      def initialize_entry_task_container(task_container, task_name, node)
        task_container.object_name = 'entry_node_entry_task_container'
        build_entry_task_layout(task_container)
        display_input = build_entry_task_display(task_container, task_name)
        editor, line_edit = build_entry_task_editor(task_container, task_name, node)
        register_task_widgets(task_container, display_input, editor, line_edit)
      end

      def build_entry_task_layout(task_container)
        QHBoxLayout.new(task_container).tap do |layout|
          layout.set_contents_margins(0, 0, 0, 0)
          layout.spacing = 0
        end
      end

      def build_entry_task_display(task_container, task_name)
        QLineEdit.new(task_container).tap do |task_input|
          task_input.object_name = 'entry_node_entry_task'
          task_input.text = task_name
          task_input.tool_tip = task_name
          task_input.placeholder_text = 'task'
          task_input.minimum_width = 220
          task_input.read_only = true
          sync_task_display_field(task_input, task_name)
          task_container.layout.add_widget(task_input)
        end
      end

      def build_entry_task_editor(task_container, task_name, node)
        QComboBox.new(task_container).tap do |editor|
          line_edit = configure_entry_task_editor(editor, task_container, task_name, node)
          task_container.layout.add_widget(editor)
          editor.hide
          return [editor, line_edit]
        end
      end

      def configure_entry_task_editor(editor, task_container, task_name, node)
        editor.object_name = 'entry_node_entry_task_editor'
        editor.editable = true
        editor.focus_policy = Qt::StrongFocus
        editor.minimum_width = 220
        editor.tool_tip = task_name
        line_edit = build_entry_task_line_edit(task_container)
        editor.instance_variable_set(:@qtimetrap_task_line_edit, line_edit)
        editor.line_edit = line_edit
        populate_entry_task_options(editor, task_name, node)
        line_edit
      end

      def build_entry_task_line_edit(task_container)
        QLineEdit.new(task_container).tap do |line_edit|
          line_edit.object_name = 'entry_node_entry_task_editor_input'
        end
      end

      def populate_entry_task_options(editor, task_name, node)
        suggestions = Array(task_suggestions_for_project&.call(node.fetch(:project_name, '').to_s))
        ([task_name] + suggestions.map(&:to_s)).reject(&:empty?).uniq.each do |suggestion|
          editor.add_item(suggestion)
        end
        editor.current_text = task_name
      end

      def bind_entry_task_input_events(task_container, entry_id)
        display_input = entry_task_display_input(task_container)
        editor = entry_task_editor(task_container)
        editor_input = entry_task_editor_line_edit(editor)

        display_input.on(:mouse_button_press) { |_| activate_entry_task_input(task_container) }
        editor_input.on(:key_press) { |event| handle_entry_task_key_press(task_container, entry_id, event) }
        editor_input.connect('returnPressed') { |_| handle_entry_task_commit(task_container, entry_id) }
        editor_input.on(:focus_out) { |_| handle_entry_task_focus_out(task_container) }
        editor.connect('textActivated') { |_| handle_entry_task_commit(task_container, entry_id, force: true) }
      end

      def entry_task_display_input(task_container)
        task_display_input_for(task_container)
      end

      def entry_task_editor(task_container)
        task_editor_for(task_container)
      end

      def entry_task_editor_line_edit(editor)
        task_editor_line_edit_for(editor) || editor.instance_variable_get(:@qtimetrap_task_line_edit)
      end

      def handle_entry_task_key_press(task_container, entry_id, event)
        return unless enter_key?(event)

        handle_entry_task_commit(task_container, entry_id)
      end

      def handle_entry_task_commit(task_container, entry_id, force: false)
        editor = entry_task_editor(task_container)
        editor_input = entry_task_editor_line_edit(editor)
        return if editor_input.is_read_only && !force

        task_name = editor.current_text.to_s
        sync_entry_task_display(task_container, task_name)
        deactivate_entry_task_input(task_container)
        return unless on_entry_task_change

        on_entry_task_change.call(entry_id, task_name)
      end
    end
  end
end
