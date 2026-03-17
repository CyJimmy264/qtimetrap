# frozen_string_literal: true

module QTimetrap
  # Shared helpers for naming and creating common Qt widgets.
  module QtUiHelpers
    private

    def build_label(parent_widget, object_name, text, width: nil, height: nil)
      QLabel.new(parent_widget).tap do |label|
        label.object_name = object_name
        label.text = text if text
        label.fixed_width = width if width
        label.fixed_height = height if height
      end
    end

    def build_button(parent_widget, name, text, width, height)
      QPushButton.new(parent_widget).tap do |button|
        button.object_name = name
        button.text = text
        button.focus_policy = Qt::NoFocus
        button.fixed_width = width if width&.positive?
        button.fixed_height = height
      end
    end
  end
end
