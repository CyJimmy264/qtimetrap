# frozen_string_literal: true

module QTimetrap
  module Components
    # Renders grouped time entry lines in a scrollable list.
    class EntriesListComponent
      attr_reader :widget

      def initialize(parent:)
        @parent = parent
        @rows = []

        build
      end

      def render(lines)
        rebuild_host
        lines.each { |line| add_row(line) }
        add_bottom_stretch
      end

      private

      attr_reader :parent, :rows, :host, :host_layout

      def build
        @widget = build_scroll_area
        @host = build_host
        @host_layout = build_host_layout
        widget.set_widget(host)
      end

      def add_row(line)
        label = QLabel.new(host)
        set_name(label, row_name(line))
        label.set_text(line)
        label.set_fixed_height(32)
        host_layout.add_widget(label)
        label.show
        rows << label
      end

      def add_bottom_stretch
        host_layout.add_stretch(1)
      end

      def build_scroll_area
        QScrollArea.new(parent).tap do |area|
          set_name(area, 'entries_scroll')
          area.set_widget_resizable(1)
        end
      end

      def build_host
        QWidget.new(parent).tap do |container|
          set_name(container, 'entries_host')
        end
      end

      def build_host_layout
        QVBoxLayout.new(host).tap do |layout|
          layout.set_contents_margins(14, 10, 14, 10)
          layout.set_spacing(2)
        end
      end

      def rebuild_host
        old_host = host
        rows.each(&:hide)
        rows.clear
        @host = build_host
        @host_layout = build_host_layout
        widget.set_widget(host)
        return unless old_host && old_host.respond_to?(:dispose)

        old_host.dispose
      end

      def row_name(line)
        if line.start_with?('    ')
          'entry_row_detail'
        elsif line.start_with?('  ')
          'entry_row_project'
        else
          'entry_row_day'
        end
      end

      def set_name(widget, value)
        if widget.respond_to?(:set_object_name)
          widget.set_object_name(value)
        elsif widget.respond_to?(:setObjectName)
          widget.setObjectName(value)
        end
      end
    end
  end
end
