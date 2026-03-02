# frozen_string_literal: true

module QTimetrap
  # Shared helpers for naming and creating common Qt widgets.
  module QtUiHelpers
    private

    def build_label(parent_widget, object_name, text, width: nil, height: nil)
      QLabel.new(parent_widget).tap do |label|
        label.set_object_name(object_name)
        label.set_text(text) if text
        label.set_fixed_width(width) if width
        label.set_fixed_height(height) if height
      end
    end

    def build_button(parent_widget, name, text, width, height)
      QPushButton.new(parent_widget).tap do |button|
        button.set_object_name(name)
        button.set_text(text)
        button.set_fixed_width(width) if width&.positive?
        button.set_fixed_height(height)
      end
    end
  end
end
