# frozen_string_literal: true

module QTimetrap
  module Views
    # Keyboard shortcut handlers for MainWindow runtime.
    module MainWindowRuntimeKeyHelpers
      private

      def on_key_press(event)
        key = extract_event_value(event, :a) || 0
        modifiers = extract_event_value(event, :b) || 0
        ctrl_mask = Qt::ControlModifier
        quit_key = Qt::Key_Q
        request_shutdown if modifiers.anybits?(ctrl_mask) && key == quit_key
      end
    end
  end
end
