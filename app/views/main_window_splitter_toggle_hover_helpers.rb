# frozen_string_literal: true

module QTimetrap
  module Views
    # Hover and delayed hide behavior for splitter toggle button.
    module MainWindowSplitterToggleHoverHelpers
      SIDEBAR_TOGGLE_HIDE_DELAY_MS = 40

      private

      def bind_toggle_zone_events(zone:, button:, state:)
        zone.on(:enter) { |_| on_toggle_zone_enter(button: button, state: state) }
        zone.on(:leave) { |_| on_toggle_zone_leave(button: button, state: state) }
      end

      def bind_toggle_button_events(button:, state:)
        button.on(:enter) { |_| on_toggle_button_enter(button: button, state: state) }
        button.on(:leave) { |_| on_toggle_button_leave(button: button, state: state) }
      end

      def on_toggle_zone_enter(button:, state:)
        state[:zone_hovered] = true
        cancel_toggle_hide(state)
        button.show
        button.raise
      end

      def on_toggle_zone_leave(button:, state:)
        state[:zone_hovered] = false
        schedule_toggle_hide(button: button, state: state)
      end

      def on_toggle_button_enter(button:, state:)
        state[:button_hovered] = true
        cancel_toggle_hide(state)
        button.raise
      end

      def on_toggle_button_leave(button:, state:)
        state[:button_hovered] = false
        schedule_toggle_hide(button: button, state: state)
      end

      def hide_toggle_button_unless_hovered(button:, state:)
        show = state[:button_hovered] || state[:zone_hovered]
        button.visible = show
      end

      def schedule_toggle_hide(button:, state:)
        timer = state[:hide_timer] ||= build_toggle_hide_timer(button, state)
        timer.stop
        timer.start
      end

      def cancel_toggle_hide(state)
        timer = state[:hide_timer]
        timer&.stop
      end

      def build_toggle_hide_timer(button, state)
        QTimer.new(button).tap do |timer|
          timer.interval = SIDEBAR_TOGGLE_HIDE_DELAY_MS
          timer.connect('timeout') do |_|
            timer.stop
            hide_toggle_button_unless_hovered(button: button, state: state)
          end
        end
      end
    end
  end
end
