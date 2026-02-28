# frozen_string_literal: true

module QTimetrap
  module Components
    class EntriesListComponent
      def initialize(parent:, x:, y:, width:, height:)
        @parent = parent
        @rows = []

        @scroll = QScrollArea.new(parent)
        set_name(scroll, 'entries_scroll')
        scroll.set_widget_resizable(0)

        @host = QWidget.new(parent)
        set_name(host, 'entries_host')
        scroll.set_widget(host)

        @width = width
        relayout(x: x, y: y, width: width, height: height)
      end

      def relayout(x:, y:, width:, height:)
        @width = width
        scroll.set_geometry(x, y, width, height)
        host.set_geometry(0, 0, width - 20, [host.height, 900].max)

        y_pos = 10
        rows.each do |label|
          label.set_geometry(14, y_pos, width - 54, 32)
          y_pos += 34
        end
      end

      def render(lines)
        rows.each(&:hide)
        rows.clear

        y = 10
        lines.each do |line|
          label = QLabel.new(host)
          set_name(label, row_name(line))
          label.set_geometry(14, y, width - 54, 32)
          label.set_text(line)
          label.show
          rows << label
          y += 34
        end

        host.set_geometry(0, 0, width - 20, [y + 20, 900].max)
      end

      private

      attr_reader :parent, :scroll, :host, :rows, :width

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
