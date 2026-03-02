# frozen_string_literal: true

module QTimetrap
  module Entries
    # Node text/object-name helpers for entries tree rendering.
    module NodePresentationHelpers
      private

      def object_name_for(node)
        case node.fetch(:type)
        when :week then 'entry_node_week'
        when :day then 'entry_node_day'
        when :project then 'entry_node_project'
        when :entry then 'entry_node_entry'
        else 'entry_node_empty'
        end
      end

      def indent(level)
        '  ' * level
      end

      def branch_button_text(level, label, expanded_state)
        prefix = expanded_state ? '▾' : '▸'
        "#{indent(level)}#{prefix}  #{label}"
      end
    end
  end
end
