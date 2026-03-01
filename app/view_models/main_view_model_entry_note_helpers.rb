# frozen_string_literal: true

module QTimetrap
  module ViewModels
    # Entry note update behavior for MainViewModel.
    module MainViewModelEntryNoteHelpers
      def update_entry_note(entry_id, note)
        normalized_id = entry_id.to_i
        return if normalized_id.zero?

        gateway.update_note(normalized_id, note.to_s)
        @entries = entries.map { |entry| updated_entry_with_note(entry, normalized_id, note.to_s) }
      end

      private

      def updated_entry_with_note(entry, entry_id, note)
        return entry unless entry.id.to_i == entry_id

        Models::TimeEntry.new(
          id: entry.id,
          note: note,
          sheet: entry.sheet,
          start_time: entry.start_time,
          end_time: entry.end_time
        )
      end
    end
  end
end
