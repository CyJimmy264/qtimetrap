# frozen_string_literal: true

module QTimetrap
  module Entries
    # Entry-leaf helpers for archive action button.
    module LeafArchiveHelpers
      private

      def build_entry_archive_button(row, node)
        QPushButton.new(row).tap do |button|
          button.object_name = 'entry_node_entry_archive'
          button.text = '🗃'
          button.tool_tip = 'Toggle archive state'
          button.focus_policy = Qt::NoFocus
          button.fixed_width = 28
          button.fixed_height = 24
          entry_id = resolve_entry_id(node)
          button.connect('clicked') { |_| on_entry_archive&.call(entry_id) }
        end
      end
    end
  end
end
