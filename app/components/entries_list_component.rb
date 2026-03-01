# frozen_string_literal: true

module QTimetrap
  module Components
    # Renders expandable week/day/project nodes and leaf time entries.
    class EntriesListComponent
      include QtUiHelpers
      include EntriesTreeHelpers
      include EntriesRenderHelpers

      attr_reader :widget

      def initialize(parent:)
        @parent = parent
        initialize_state!
        build
      end

      def render(nodes)
        return if rendering

        @rendering = true
        @current_nodes = Array(nodes)
        @branch_bindings = {}
        with_widget_updates_suspended { render_contents }
      ensure
        @rendering = false
      end

      private

      attr_reader :parent, :host, :host_layout, :expanded, :current_nodes, :branch_bindings, :rendering,
                  :scroll_area

      def build
        @widget = QWidget.new(parent)
        widget.set_object_name('entries_panel')
        panel_layout = build_panel_layout
        panel_layout.add_widget(build_toolbar(parent_widget: widget))
        @scroll_area = build_scroll_area
        panel_layout.add_widget(scroll_area)
        panel_layout.set_stretch(1, 1)
        rebuild_host!
      end

      def initialize_state!
        @expanded = {}
        @current_nodes = []
        @branch_bindings = {}
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
    end
  end
end
