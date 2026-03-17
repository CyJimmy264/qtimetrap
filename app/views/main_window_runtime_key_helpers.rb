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
        target = click_target_widget(source_widget, event)
        return if editable_input?(target) || entries.task_editor_widget?(target)

        blur_editable_input(focused) if editable_input?(focused)
        entries.close_active_task_editor
      end

      def active_line_edit?
        focused = window.focus_widget
        editable_input?(focused)
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

      def editable_task_combo?(widget)
        return false unless widget.is_a?(QComboBox)

        widget.object_name == 'entry_node_entry_task_editor'
      end

      def editable_input?(widget)
        editable_line_edit?(widget) || editable_task_combo?(widget)
      end

      def blur_editable_input(widget)
        if editable_task_combo?(widget)
          widget.line_edit.clear_focus
          widget.clear_focus
          return
        end

        widget.clear_focus
      end
    end
  end
end
