# frozen_string_literal: true

module QTimetrap
  module Entries
    # Render-cycle helpers to reduce flicker during entries tree rebuild.
    module RenderHelpers
      private

      def with_widget_updates_suspended
        widget.set_updates_enabled(false)
        yield
      ensure
        widget.set_updates_enabled(true)
        widget.update
      end

      def render_contents
        rebuild_host!
        render_nodes(current_nodes, 0)
        adjust_node_widths
        host_layout.add_stretch(1)
      end
    end
  end
end
