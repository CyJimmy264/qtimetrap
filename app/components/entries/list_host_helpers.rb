# frozen_string_literal: true

module QTimetrap
  module Entries
    # Host/viewport helpers for entries list rendering.
    module ListHostHelpers
      private

      def build_host
        QWidget.new(scroll_area).tap { |container| container.object_name = 'entries_host' }
      end

      def build_host_layout
        QVBoxLayout.new(host).tap do |layout|
          layout.set_contents_margins(14, 10, 14, 10)
          layout.spacing = 2
        end
      end

      def rebuild_host!
        previous_host = scroll_area.take_widget
        previous_host.delete_later if previous_host
        @host = build_host
        apply_entry_widget_styles(host, %w[entries_host])
        @host_layout = build_host_layout
        scroll_area.widget = host
      end
    end
  end
end
