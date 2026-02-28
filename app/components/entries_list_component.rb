# frozen_string_literal: true

module QTimetrap
  module Components
    class EntriesListComponent
      attr_reader :widget

      def initialize(parent:)
        @parent = parent
        @rows = []

        build
      end

      def render(lines)
        clear_rows

        lines.each do |line|
          label = QLabel.new(host)
          set_name(label, row_name(line))
          label.set_text(line)
          label.set_fixed_height(32)
          host_layout.add_widget(label)
          label.show
          rows << label
        end

        host_layout.add_stretch(1)
      end

      private

      attr_reader :parent, :rows, :host, :host_layout

      def build
        @widget = QScrollArea.new(parent)
        set_name(widget, 'entries_scroll')
        widget.set_widget_resizable(1)

        @host = QWidget.new(parent)
        set_name(host, 'entries_host')
        @host_layout = QVBoxLayout.new(host)
        host_layout.set_contents_margins(14, 10, 14, 10)
        host_layout.set_spacing(2)

        widget.set_widget(host)
      end

      def clear_rows
        rows.each(&:hide)
        rows.clear

        while host_layout.count.positive?
          item = host_layout.item_at(0)
          host_layout.remove_item(item)
        end
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
