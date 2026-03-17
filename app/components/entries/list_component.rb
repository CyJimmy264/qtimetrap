# frozen_string_literal: true

module QTimetrap
  module Entries
    # Renders expandable week/day/project nodes and leaf time entries.
    class ListComponent
      include ListHostHelpers
      include ListStateHelpers
      include ListTaskEditorHelpers
      include QtUiHelpers
      include TreeHelpers
      include RenderHelpers

      HOST_HORIZONTAL_MARGINS = 28
      WIDTH_PADDING = 24
      TIME_FILTER_DEBOUNCE_MS = 220

      attr_reader :widget

      def initialize(parent:, callbacks: {}, task_suggestions_for_project: nil)
        @parent = parent
        @on_entry_note_change = callbacks[:on_entry_note_change]
        @on_entry_task_change = callbacks[:on_entry_task_change]
        @task_suggestions_for_project = task_suggestions_for_project
        @on_entry_time_change = callbacks[:on_entry_time_change]
        @on_entry_archive = callbacks[:on_entry_archive]
        @on_time_range_change = callbacks[:on_time_range_change]
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

      def update_time_range_inputs(from_at:, to_at:)
        @syncing_time_filters = true
        set_time_filter_state(
          toggle: time_filter_from_toggle,
          input: time_filter_from_input,
          value: from_at
        )
        set_time_filter_state(
          toggle: time_filter_to_toggle,
          input: time_filter_to_input,
          value: to_at
        )
      ensure
        @syncing_time_filters = false
      end

      def shutdown
        return unless time_filter_debounce

        time_filter_debounce.stop if time_filter_debounce.is_active
      end

      private

      attr_reader :parent, :host, :host_layout, :expanded, :current_nodes, :branch_bindings, :leaf_labels, :entry_rows,
                  :rendering, :scroll_area, :on_entry_note_change, :on_entry_task_change, :task_suggestions_for_project,
                  :on_entry_time_change, :on_entry_archive, :on_time_range_change,
                  :time_filter_from_toggle, :time_filter_to_toggle, :time_filter_from_input, :time_filter_to_input,
                  :time_filter_debounce

      def build
        @widget = QWidget.new(parent)
        widget.object_name = 'entries_panel'
        panel_layout = build_panel_layout
        @time_filter_debounce = build_time_filter_debounce_timer
        panel_layout.add_widget(build_toolbar(parent_widget: widget))
        @scroll_area = build_scroll_area
        bind_scroll_resize
        panel_layout.add_widget(scroll_area)
        panel_layout.set_stretch(1, 1)
        rebuild_host!
      end

      def branch_button_width
        available = scroll_area.width - HOST_HORIZONTAL_MARGINS - WIDTH_PADDING
        [available, 120].max
      end

      def adjust_node_widths
        width = branch_button_width
        branch_bindings.each_value { |binding| binding.fetch(:button).fixed_width = width }
        leaf_labels.each { |label| label.fixed_width = width }
        entry_rows.each { |row| row.fixed_width = width }
      end

      def build_panel_layout
        QVBoxLayout.new(widget).tap do |layout|
          layout.set_contents_margins(0, 0, 0, 0)
          layout.spacing = 6
        end
      end

      def build_scroll_area
        QScrollArea.new(widget).tap do |area|
          area.object_name = 'entries_scroll'
          area.widget_resizable = true
        end
      end

      def bind_scroll_resize
        scroll_area.on(:resize) { |_| adjust_node_widths }
      end
    end
  end
end
