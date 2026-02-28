# frozen_string_literal: true

module QTimetrap
  module Components
    # Render-cycle helpers to reduce flicker during entries tree rebuild.
    module EntriesRenderHelpers
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
        add_toolbar
        render_nodes(current_nodes, 0)
        host_layout.add_stretch(1)
      end
    end
  end
end
