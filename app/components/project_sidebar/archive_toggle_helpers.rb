# frozen_string_literal: true

module QTimetrap
  module ProjectSidebar
    # Bottom archive mode toggle button in sidebar.
    module ArchiveToggleHelpers
      private

      def build_archive_toggle_button
        QPushButton.new(widget).tap do |button|
          button.object_name = 'sidebar_archive_toggle'
          button.checkable = true
          button.focus_policy = Qt::NoFocus
          button.fixed_height = 30
          button.text = "\u{1F5C3}"
          button.tool_tip = 'Show archived entries only'
          button.connect('clicked') { |_| on_archive_mode_toggled&.call(button.is_checked) }
        end
      end
    end
  end
end
