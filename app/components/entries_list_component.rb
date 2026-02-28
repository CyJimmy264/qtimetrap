# frozen_string_literal: true

module QTimetrap
  module Components
    # Renders expandable week/day/project nodes and leaf time entries.
    class EntriesListComponent
      include QtUiHelpers
      include EntriesTreeHelpers

      attr_reader :widget

      def initialize(parent:)
        @parent = parent
        @expanded = {}
        @current_nodes = []
        build
      end

      def render(nodes)
        @current_nodes = Array(nodes)
        rebuild_host!
        add_toolbar
        render_nodes(current_nodes, 0)
        host_layout.add_stretch(1)
      end

      private

      attr_reader :parent, :host, :host_layout, :expanded, :current_nodes

      def build
        @widget = QScrollArea.new(parent)
        set_name(widget, 'entries_scroll')
        widget.set_widget_resizable(1)
        rebuild_host!
      end

      def build_host
        QWidget.new(parent).tap { |container| set_name(container, 'entries_host') }
      end

      def build_host_layout
        QVBoxLayout.new(host).tap do |layout|
          layout.set_contents_margins(14, 10, 14, 10)
          layout.set_spacing(2)
        end
      end

      def rebuild_host!
        old_host = @host
        @host = build_host
        @host_layout = build_host_layout
        widget.set_widget(host)
        old_host.dispose if old_host.respond_to?(:dispose)
      end
    end
  end
end
