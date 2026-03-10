# frozen_string_literal: true

module QTimetrap
  module Entries
    # Helper methods for entries tree rendering and expand/collapse controls.
    module TreeHelpers
      include BranchHierarchyHelpers
      include LeafArchiveHelpers
      include LeafNoteHelpers
      include LeafTaskHelpers
      include LeafTimeHelpers
      include NodePresentationHelpers
      include TreeToolbarHelpers

      private

      def on_filter_toggle_changed
        schedule_time_range_filter_changed
      end

      def set_initial_filter_ui_state
        time_filter_from_toggle.set_checked(false)
        time_filter_to_toggle.set_checked(false)
      end

      def emit_time_range_filter_changed
        return if syncing_time_filters?
        return unless on_time_range_change

        on_time_range_change.call(selected_time_filter(time_filter_from_toggle, time_filter_from_input),
                                  selected_time_filter(time_filter_to_toggle, time_filter_to_input))
      end

      def selected_time_filter(toggle, input)
        return nil unless filter_toggle_checked?(toggle)

        input.date_time
      end

      def filter_toggle_checked?(toggle)
        value = toggle.is_checked
        [true, 1].include?(value)
      end

      def expand_all!
        set_all_branch_nodes(current_nodes, true)
        apply_all_branch_states
      end

      def collapse_all!
        set_all_branch_nodes(current_nodes, false)
        apply_all_branch_states
      end

      def set_all_branch_nodes(nodes, value)
        nodes.each do |node|
          next unless branch_node?(node)

          expanded[node.fetch(:id)] = value
          set_all_branch_nodes(node.fetch(:children), value)
        end
      end

      def render_nodes(nodes, level, layout: host_layout, parent_widget: host)
        nodes.each { |node| render_node(node, level, layout: layout, parent_widget: parent_widget) }
      end

      def render_node(node, level, layout:, parent_widget:)
        if branch_node?(node)
          render_branch_node(node, level, layout: layout, parent_widget: parent_widget)
        else
          render_leaf_node(node, level, layout: layout, parent_widget: parent_widget)
        end
      end

      def render_branch_node(node, level, layout:, parent_widget:)
        node_id = node.fetch(:id)
        label = node.fetch(:label)
        expanded_state = expanded.fetch(node.fetch(:id), true)
        button = build_branch_button(node, level, expanded_state, parent_widget: parent_widget)
        layout.add_widget(button)
        children_container, children_layout = build_children_container(parent_widget)
        layout.add_widget(children_container)
        register_branch_binding(
          node_id: node_id,
          button: button,
          children_container: children_container,
          label: label,
          level: level
        )
        render_nodes(node.fetch(:children), level + 1, layout: children_layout, parent_widget: children_container)
        apply_branch_state(node_id, expanded_state)
      end

      def render_leaf_node(node, level, layout:, parent_widget:)
        if node.fetch(:type) == :entry
          render_entry_leaf_node(node, level, layout: layout, parent_widget: parent_widget)
          return
        end

        render_default_leaf_node(node, level, parent_widget: parent_widget, layout: layout)
      end

      def render_default_leaf_node(node, level, parent_widget:, layout:)
        label = QLabel.new(parent_widget)
        label.set_object_name(object_name_for(node))
        label.set_text("#{indent(level)}#{node.fetch(:label)}")
        label.set_fixed_width(branch_button_width)
        label.set_fixed_height(32)
        leaf_labels << label
        layout.add_widget(label)
      end

      def toggle_node(node_id)
        expanded[node_id] = !expanded.fetch(node_id, true)
        apply_branch_state(node_id, expanded[node_id])
      end

      def branch_node?(node)
        !node.fetch(:children).empty?
      end

      def build_branch_button(node, level, expanded_state, parent_widget:)
        text = branch_button_text(level, node.fetch(:label), expanded_state)
        button = build_button(parent_widget, object_name_for(node), text, 0, 32)
        button.set_fixed_width(branch_button_width)
        node_id = node.fetch(:id)
        button.connect('clicked') { |_| toggle_node(node_id) }
        button
      end
    end
  end
end
