# frozen_string_literal: true

module QTimetrap
  module Views
    # Archive handlers for MainWindow runtime.
    module MainWindowRuntimeArchiveHelpers
      private

      def handle_archive_mode_toggled(enabled)
        view_model.archive_mode = enabled
        render!(sync_sheet: false)
      end

      def handle_entry_archived(entry_id)
        archive_mode_active? ? view_model.unarchive_entry(entry_id) : view_model.archive_entry(entry_id)
        @pending_refresh = true
      rescue StandardError => e
        warn("[qtimetrap] archive entry failed: #{e.class}: #{e.message}")
      end

      def archive_mode_active?
        view_model.archive_mode?
      end
    end
  end
end
