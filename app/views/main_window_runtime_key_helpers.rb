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

      def on_space_shortcut
        return if active_line_edit?

        toggle_tracking_via_space
      end

      def on_mouse_button_press(event, source_widget: window)
        focused = window.focus_widget
        return unless editable_line_edit?(focused)

        target = click_target_widget(source_widget, event)
        return if editable_line_edit?(target)

        focused.clear_focus
      end

      def active_line_edit?
        focused = window.focus_widget
        editable_line_edit?(focused)
      end

      def toggle_tracking_via_space
        if view_model.running_current_sheet?
          handle_stop
        else
          handle_start(controls.task_input.text.to_s, controls.project_input.text.to_s)
        end
      end

      def click_target_widget(source_widget, event)
        source_widget.child_at(extract_event_value(event, :a), extract_event_value(event, :b))
      end

      def editable_line_edit?(widget)
        widget.is_a?(QLineEdit) && !widget.is_read_only
      end
    end
  end
end
