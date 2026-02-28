# frozen_string_literal: true

module QTimetrap
  module Components
    # Shared helpers for naming and creating common Qt widgets.
    module QtUiHelpers
      private

      def set_name(target, value)
        if target.respond_to?(:set_object_name)
          target.set_object_name(value)
        elsif target.respond_to?(:setObjectName)
          target.setObjectName(value)
        end
      end

      def build_label(parent_widget, object_name, text, width: nil, height: nil)
        QLabel.new(parent_widget).tap do |label|
          set_name(label, object_name)
          label.set_text(text) if text
          label.set_fixed_width(width) if width
          label.set_fixed_height(height) if height
        end
      end

      def build_button(parent_widget, name, text, width, height)
        QPushButton.new(parent_widget).tap do |button|
          set_name(button, name)
          button.set_text(text)
          button.set_fixed_width(width)
          button.set_fixed_height(height)
        end
      end
    end
  end
end
