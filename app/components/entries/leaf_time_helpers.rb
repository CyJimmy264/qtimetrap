# frozen_string_literal: true

module QTimetrap
  module Entries
    # Entry-leaf helpers for editable start/end time controls.
    module LeafTimeHelpers
      private

      def add_entry_time_widgets(row_layout, row, node)
        start_input = build_entry_time_input(
          row,
          object_name: 'entry_node_entry_start',
          value: node.fetch(:start_label, '--:--'),
          placeholder: '--:--'
        )
        end_input = build_entry_time_input(
          row,
          object_name: 'entry_node_entry_end',
          value: node.fetch(:end_label, 'running'),
          placeholder: 'running'
        )
        row_layout.add_widget(build_entry_time_group(row, start_input, end_input))
        [start_input, end_input]
      end

      def build_entry_time_group(row, start_input, end_input)
        QWidget.new(row).tap do |time_group|
          time_group.object_name = 'entry_node_entry_time_group'
          QHBoxLayout.new(time_group).tap do |time_layout|
            time_layout.set_contents_margins(0, 0, 0, 0)
            time_layout.spacing = 4
            time_layout.add_widget(start_input)
            time_layout.add_widget(build_entry_time_separator(time_group))
            time_layout.add_widget(end_input)
          end
        end
      end

      def build_entry_time_separator(row)
        QLabel.new(row).tap do |separator|
          separator.object_name = 'entry_node_entry_time_sep'
          separator.text = '-'
        end
      end

      def build_entry_time_input(row, object_name:, value:, placeholder:)
        QLineEdit.new(row).tap do |time_input|
          time_input.object_name = object_name
          time_input.text = value.to_s
          time_input.placeholder_text = placeholder
          time_input.alignment = Qt::AlignCenter
          time_input.read_only = true
          time_input.fixed_width = 58
        end
      end

      def bind_entry_time_input_events(start_input, end_input, entry_id)
        bind_single_time_input(start_input, entry_id, start_input, end_input)
        bind_single_time_input(end_input, entry_id, start_input, end_input)
      end

      def bind_single_time_input(time_input, entry_id, start_input, end_input)
        time_input.on(:mouse_button_press) { |_| activate_entry_note_input(time_input) }
        time_input.on(:key_press) do |event|
          handle_entry_time_key_press(
            time_input: time_input,
            entry_id: entry_id,
            start_input: start_input,
            end_input: end_input,
            event: event
          )
        end
        time_input.connect('returnPressed') do |_|
          handle_entry_time_commit(
            time_input: time_input,
            entry_id: entry_id,
            start_input: start_input,
            end_input: end_input
          )
        end
        time_input.on(:focus_out) { |_| handle_entry_note_focus_out(time_input) }
      end

      def handle_entry_time_key_press(time_input:, entry_id:, start_input:, end_input:, event:)
        return unless enter_key?(event)

        handle_entry_time_commit(
          time_input: time_input,
          entry_id: entry_id,
          start_input: start_input,
          end_input: end_input
        )
      end

      def handle_entry_time_commit(time_input:, entry_id:, start_input:, end_input:)
        return if time_input.is_read_only

        deactivate_entry_note_input(time_input)
        return unless on_entry_time_change

        on_entry_time_change.call(entry_id, start_input.text.to_s, end_input.text.to_s)
      end
    end
  end
end
