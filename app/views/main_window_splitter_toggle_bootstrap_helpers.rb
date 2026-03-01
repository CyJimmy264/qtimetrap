# frozen_string_literal: true

module QTimetrap
  module Views
    # Bootstrap helpers to stabilize initial splitter toggle placement.
    module MainWindowSplitterToggleBootstrapHelpers
      private

      def schedule_initial_toggle_reposition(splitter:, sidebar_widget:, button:, zone:)
        attempts = { count: 0 }
        context = { splitter: splitter, sidebar_widget: sidebar_widget, button: button, zone: zone }
        timer = QTimer.new(zone)
        timer.set_interval(120)
        timer.connect('timeout') do |_|
          tick_initial_reposition(
            attempts: attempts,
            timer: timer,
            context: context
          )
        end
        timer.start
      end

      def tick_initial_reposition(attempts:, timer:, context:)
        attempts[:count] += 1
        reposition_toggle_affordance(**context)
        return unless attempts[:count] >= 4

        timer.stop
        timer.delete_later
      end
    end
  end
end
