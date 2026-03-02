# frozen_string_literal: true

module QTimetrap
  module Views
    # Entry time change runtime behavior for MainWindow.
    module MainWindowRuntimeEntryTimeHelpers
      private

      def handle_entry_time_changed(entry_id, start_text, end_text)
        view_model.update_entry_time(entry_id, start_text, end_text)
        @pending_refresh = true
      rescue StandardError => e
        warn("[qtimetrap] update time failed: #{e.class}: #{e.message}")
      end
    end
  end
end
