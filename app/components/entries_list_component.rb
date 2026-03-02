# frozen_string_literal: true

module QTimetrap
  module Components
    # Renders expandable week/day/project nodes and leaf time entries.
    class EntriesListComponent
      include QtUiHelpers
      include EntriesTreeHelpers
      include EntriesRenderHelpers

      HOST_HORIZONTAL_MARGINS = 28
      WIDTH_PADDING = 24

      attr_reader :widget

      def initialize(parent:, on_entry_note_change: nil, on_entry_time_change: nil)
        @parent = parent
        @on_entry_note_change = on_entry_note_change
        @on_entry_time_change = on_entry_time_change
        initialize_state!
        build
      end

      def render(nodes)
        return if rendering

        @rendering = true
        @current_nodes = Array(nodes)
        @branch_bindings = {}
        @leaf_labels = []
        @entry_rows = []
        with_widget_updates_suspended { render_contents }
      ensure
        @rendering = false
      end

      private

      attr_reader :parent, :host, :host_layout, :expanded, :current_nodes, :branch_bindings, :leaf_labels, :entry_rows,
                  :rendering, :scroll_area, :on_entry_note_change, :on_entry_time_change

      def build
        @widget = QWidget.new(parent)
        widget.set_object_name('entries_panel')
        panel_layout = build_panel_layout
        panel_layout.add_widget(build_toolbar(parent_widget: widget))
        @scroll_area = build_scroll_area
        bind_scroll_resize
        panel_layout.add_widget(scroll_area)
        panel_layout.set_stretch(1, 1)
        rebuild_host!
      end

      def initialize_state!
        @expanded = {}
        @current_nodes = []
        @branch_bindings = {}
        @leaf_labels = []
        @entry_rows = []
        @rendering = false
      end

      def build_host
        QWidget.new(scroll_area).tap { |container| container.set_object_name('entries_host') }
      end

      def build_host_layout
        QVBoxLayout.new(host).tap do |layout|
          layout.set_contents_margins(14, 10, 14, 10)
          layout.set_spacing(2)
        end
      end

      def rebuild_host!
        @host = build_host
        @host_layout = build_host_layout
        scroll_area.set_widget(host)
      end

      def branch_button_width
        available = scroll_area.width - HOST_HORIZONTAL_MARGINS - WIDTH_PADDING
        [available, 120].max
      end

      def adjust_node_widths
        width = branch_button_width
        branch_bindings.each_value { |binding| binding.fetch(:button).set_fixed_width(width) }
        leaf_labels.each { |label| label.set_fixed_width(width) }
        entry_rows.each { |row| row.set_fixed_width(width) }
      end

      def build_panel_layout
        QVBoxLayout.new(widget).tap do |layout|
          layout.set_contents_margins(0, 0, 0, 0)
          layout.set_spacing(6)
        end
      end

      def build_scroll_area
        QScrollArea.new(widget).tap do |area|
          area.set_object_name('entries_scroll')
          area.set_widget_resizable(true)
        end
      end

      def bind_scroll_resize
        scroll_area.on(:resize) { |_| adjust_node_widths }
      end
    end
  end
end
