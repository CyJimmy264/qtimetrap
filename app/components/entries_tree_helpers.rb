# frozen_string_literal: true

module QTimetrap
  module Components
    # Helper methods for entries tree rendering and expand/collapse controls.
    module EntriesTreeHelpers
      include EntriesBranchHierarchyHelpers

      private

      def build_toolbar(parent_widget:)
        toolbar = QWidget.new(parent_widget)
        toolbar.set_object_name('entries_toolbar')
        layout = QHBoxLayout.new(toolbar)
        layout.set_contents_margins(0, 0, 0, 0)
        layout.set_spacing(8)
        layout.add_widget(build_toolbar_button(toolbar, 'entries_expand_all', 'EXPAND ALL') { expand_all! })
        layout.add_widget(build_toolbar_button(toolbar, 'entries_collapse_all', 'COLLAPSE ALL') { collapse_all! })
        layout.add_stretch(1)
        toolbar
      end

      def build_toolbar_button(parent_widget, name, text, &block)
        build_button(parent_widget, name, text, 136, 28).tap { |button| button.connect('clicked') { |_| yield } }
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

      def build_branch_button(node, level, expanded_state, parent_widget:)
        text = branch_button_text(level, node.fetch(:label), expanded_state)
        button = build_button(parent_widget, object_name_for(node), text, 0, 32)
        button.set_fixed_width(branch_button_width)
        node_id = node.fetch(:id)
        button.connect('clicked') { |_| toggle_node(node_id) }
        button
      end

      def branch_button_text(level, label, expanded_state)
        prefix = expanded_state ? '▾' : '▸'
        "#{indent(level)}#{prefix}  #{label}"
      end
    end
  end
end
