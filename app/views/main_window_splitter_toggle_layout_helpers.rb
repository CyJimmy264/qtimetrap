# frozen_string_literal: true

module QTimetrap
  module Views
    # Coordinate helpers for splitter toggle affordance.
    module MainWindowSplitterToggleLayoutHelpers
      SIDEBAR_TOGGLE_W = 20
      SIDEBAR_TOGGLE_H = 56

      private

      def toggle_x(splitter:, sidebar_widget:)
        sidebar_width = sidebar_widget.is_visible ? sidebar_widget.width : 0
        splitter.x + [sidebar_width - (SIDEBAR_TOGGLE_W / 2), 0].max
      end

      def toggle_y(splitter_height:)
        y_center = ((splitter_height - SIDEBAR_TOGGLE_H) / 2)
        max_y = [splitter_height - SIDEBAR_TOGGLE_H - 8, 8].max
        y_center.clamp(8, max_y)
      end
    end
  end
end
