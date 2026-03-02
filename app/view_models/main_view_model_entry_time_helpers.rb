# frozen_string_literal: true

module QTimetrap
  module ViewModels
    # Entry time update behavior for MainViewModel.
    module MainViewModelEntryTimeHelpers
      def update_entry_time(entry_id, start_text, end_text)
        normalized_id = entry_id.to_i
        return if normalized_id.zero?

        entry = entries.find { |item| item.id.to_i == normalized_id }
        raise ArgumentError, "Entry not found: #{normalized_id}" unless entry

        start_time = parse_entry_clock_value(entry.start_time, start_text)
        end_time = parse_entry_clock_value(entry.end_time || entry.start_time, end_text)

        gateway.update_time(normalized_id, start_time: start_time, end_time: end_time)
        refresh!
      end

      private

      def parse_entry_clock_value(reference_time, value)
        text = value.to_s.strip
        return nil if text.empty? || text == 'running'

        hour, min = parse_clock_components(text, value)

        base = reference_time || Time.now
        Time.new(base.year, base.month, base.day, hour, min, 0, base.utc_offset)
      end

      def parse_clock_components(text, original_value)
        match = text.match(/\A(\d{1,2}):(\d{2})\z/)
        raise ArgumentError, "Invalid time value: #{original_value}" unless match

        hour = match[1].to_i
        min = match[2].to_i
        raise ArgumentError, "Invalid time value: #{original_value}" if hour > 23 || min > 59

        [hour, min]
      end
    end
  end
end
