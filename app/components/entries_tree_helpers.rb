# frozen_string_literal: true

module QTimetrap
  module Components
    # Helper methods for entries tree rendering and expand/collapse controls.
    module EntriesTreeHelpers
      private

      def add_toolbar
        toolbar = QWidget.new(host)
        set_name(toolbar, 'entries_toolbar')
        layout = QHBoxLayout.new(toolbar)
        layout.set_contents_margins(0, 0, 0, 0)
        layout.set_spacing(8)
        layout.add_widget(build_toolbar_button(toolbar, 'entries_expand_all', 'EXPAND ALL') { expand_all! })
        layout.add_widget(build_toolbar_button(toolbar, 'entries_collapse_all', 'COLLAPSE ALL') { collapse_all! })
        layout.add_stretch(1)
        host_layout.add_widget(toolbar)
      end

      def build_toolbar_button(parent_widget, name, text, &block)
        build_button(parent_widget, name, text, 136, 28).tap do |button|
          button.connect('clicked') { |_| block.call }
        end
      end

      def expand_all!
        set_all_branch_nodes(current_nodes, true)
        schedule_rerender
      end

      def collapse_all!
        set_all_branch_nodes(current_nodes, false)
        schedule_rerender
      end

      def set_all_branch_nodes(nodes, value)
        nodes.each do |node|
          next unless branch_node?(node)

          expanded[node.fetch(:id)] = value
          set_all_branch_nodes(node.fetch(:children), value)
        end
      end

      def render_nodes(nodes, level)
        nodes.each { |node| render_node(node, level) }
      end

      def render_node(node, level)
        if branch_node?(node)
          render_branch_node(node, level)
        else
          render_leaf_node(node, level)
        end
      end

      def render_branch_node(node, level)
        expanded_state = expanded.fetch(node.fetch(:id), true)
        button = build_branch_button(node, level, expanded_state)
        host_layout.add_widget(button)
        render_nodes(node.fetch(:children), level + 1) if expanded_state
      end

      def render_leaf_node(node, level)
        label = QLabel.new(host)
        set_name(label, object_name_for(node))
        label.set_text("#{indent(level)}#{node.fetch(:label)}")
        label.set_fixed_height(32)
        host_layout.add_widget(label)
      end

      def toggle_node(node_id)
        expanded[node_id] = !expanded.fetch(node_id, true)
        schedule_rerender
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

      def build_branch_button(node, level, expanded_state)
        text = branch_button_text(level, node.fetch(:label), expanded_state)
        button = build_button(host, object_name_for(node), text, 0, 32)
        button.connect('clicked') { |_| toggle_node(node.fetch(:id)) }
        button
      end

      def branch_button_text(level, label, expanded_state)
        prefix = expanded_state ? '▾' : '▸'
        "#{indent(level)}#{prefix}  #{label}"
      end

      def schedule_rerender
        timer = QTimer.new(widget)
        timer.set_interval(0)
        timer.connect('timeout') do |_|
          timer.stop if timer.respond_to?(:stop)
          render(current_nodes)
          timer.dispose if timer.respond_to?(:dispose)
        end
        timer.start
      end
    end
  end
end
