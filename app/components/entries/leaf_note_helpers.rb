# frozen_string_literal: true

module QTimetrap
  module Entries
    # Entry-leaf row builders for editable note nodes.
    module LeafNoteHelpers
      private

      def render_entry_leaf_node(node, level, layout:, parent_widget:)
        row = build_entry_row(parent_widget)
        row_layout = build_entry_row_layout(row)
        start_input, end_input = add_entry_time_widgets(row_layout, row, node)
        row_layout.add_widget(build_entry_prefix_label(row, node, level))
        row_layout.add_widget(build_entry_note_input(row, node))
        bind_entry_time_input_events(start_input, end_input, resolve_entry_id(node))
        row_layout.set_stretch(2, 1)
        entry_rows << row
        layout.add_widget(row)
      end

      def build_entry_row(parent_widget)
        QWidget.new(parent_widget).tap do |row|
          row.set_object_name('entry_node_entry_row')
          row.set_fixed_width(branch_button_width)
          row.set_fixed_height(32)
        end
      end

      def build_entry_row_layout(row)
        QHBoxLayout.new(row).tap do |layout|
          layout.set_contents_margins(8, 0, 8, 0)
          layout.set_spacing(6)
        end
      end

      def build_entry_prefix_label(row, node, level)
        QLabel.new(row).tap do |prefix_label|
          prefix_label.set_object_name('entry_node_entry_prefix')
          prefix_label.set_text("#{indent(level)}#{node.fetch(:prefix, node.fetch(:label))}")
        end
      end

      def build_entry_note_input(row, node)
        QLineEdit.new(row).tap do |note_input|
          note_input.set_object_name('entry_node_entry_note')
          note_input.text = node.fetch(:note, '')
          note_input.set_placeholder_text('(no note)')
          note_input.set_read_only(true)
          bind_entry_note_input_events(note_input, resolve_entry_id(node))
        end
      end

      def bind_entry_note_input_events(note_input, entry_id)
        note_input.on(:mouse_button_press) { |_| activate_entry_note_input(note_input) }
        note_input.on(:key_press) { |event| handle_entry_note_key_press(note_input, entry_id, event) }
        note_input.connect('returnPressed') { |_| handle_entry_note_commit(note_input, entry_id) }
        note_input.on(:focus_out) { |_| handle_entry_note_focus_out(note_input) }
      end

      def resolve_entry_id(node)
        node.fetch(:entry_id, node.fetch(:id).to_s.sub('entry:', ''))
      end

      def handle_entry_note_commit(note_input, entry_id)
        return if note_input.is_read_only

        note = note_input.text.to_s
        deactivate_entry_note_input(note_input)
        return unless on_entry_note_change

        on_entry_note_change.call(entry_id, note)
      end

      def activate_entry_note_input(note_input)
        note_input.set_read_only(false)
        note_input.set_focus
      end

      def deactivate_entry_note_input(note_input)
        note_input.set_read_only(true)
        note_input.clear_focus
      end

      def handle_entry_note_key_press(note_input, entry_id, event)
        return unless enter_key?(event)

        handle_entry_note_commit(note_input, entry_id)
      end

      def handle_entry_note_focus_out(note_input)
        deactivate_entry_note_input(note_input)
      end

      def enter_key?(event)
        key = event_key_code(event)
        [Qt::Key_Return, Qt::Key_Enter].include?(key)
      end

      def event_key_code(event)
        return event[:a] if event.is_a?(Hash) && event.key?(:a)
        return event['a'] if event.is_a?(Hash) && event.key?('a')

        event.respond_to?(:key) ? event.key : nil
      end
    end
  end
end
