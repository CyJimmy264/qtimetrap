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

      attr_reader :parent, :host, :host_layout, :expanded, :current_nodes, :branch_bindings, :rendering

      def build
        @widget = QScrollArea.new(parent)
        widget.set_object_name('entries_scroll')
        widget.set_widget_resizable(true)
        rebuild_host!
      end

      def initialize_state!
        @expanded = {}
        @current_nodes = []
        @branch_bindings = {}
        @rendering = false
      end

      def build_host
        QWidget.new(parent).tap { |container| container.set_object_name('entries_host') }
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
        widget.set_widget(host)
      end

      def branch_button_minimum_width
        base = [host.width, widget.width].max
        [base - 10, 120].max
      end
    end
  end
end
