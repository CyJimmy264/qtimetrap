# frozen_string_literal: true

module QTimetrap
  module ViewModels
    # Entry task move behavior for MainViewModel.
    module MainViewModelEntryTaskHelpers
      def update_entry_task(entry_id, task_name)
        normalized_id = entry_id.to_i
        return if normalized_id.zero?

        entry = find_entry_for_task_update(normalized_id)
        normalized_task = normalize_target_task(task_name)
        gateway.update_task(normalized_id, target_sheet_for_entry(entry, normalized_task))
        self.current_task_input = normalized_task if entry.running?
        refresh!
      end

      private

      def find_entry_for_task_update(entry_id)
        entry = entries.find { |item| item.id.to_i == entry_id }
        raise ArgumentError, "Entry not found: #{entry_id}" unless entry

        entry
      end

      def normalize_target_task(task_name)
        value = normalize_text(task_name).strip
        raise ArgumentError, 'Task is required' if value.empty?

        value
      end

      def target_sheet_for_entry(entry, task_name)
        "#{entry.project}|#{task_name}"
      end
    end
  end
end
