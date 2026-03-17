# frozen_string_literal: true

module QTimetrap
  module Entries
    # Hierarchical branch container/show-hide helpers for entries tree UI.
    module BranchHierarchyHelpers
      private

      def build_children_container(parent_widget)
        container = QWidget.new(parent_widget)
        container.object_name = 'entry_node_children'
        layout = QVBoxLayout.new(container)
        layout.set_contents_margins(0, 0, 0, 0)
        layout.spacing = 2
        [container, layout]
      end

      def register_branch_binding(node_id:, button:, children_container:, label:, level:)
        branch_bindings[node_id] = {
          button: button,
          children_container: children_container,
          label: label,
          level: level
        }
      end

      def apply_all_branch_states
        branch_bindings.each_key { |node_id| apply_branch_state(node_id, expanded.fetch(node_id, true)) }
      end

      def apply_branch_state(node_id, visible)
        binding = branch_bindings[node_id]
        return unless binding

        binding.fetch(:children_container).visible = visible
        text = branch_button_text(binding.fetch(:level), binding.fetch(:label), visible)
        binding.fetch(:button).text = text
      end
    end
  end
end
