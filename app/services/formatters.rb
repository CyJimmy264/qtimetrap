# frozen_string_literal: true

module QTimetrap
  module Services
    # Stateless value formatters used by view models and UI rendering.
    module Formatters
      module_function

      def seconds_to_hms(seconds)
        seconds = [seconds.to_i, 0].max
        hours = seconds / 3600
        minutes = (seconds % 3600) / 60
        secs = seconds % 60
        format('%<h>02d:%<m>02d:%<s>02d', h: hours, m: minutes, s: secs)
      end

      def time_range(entry)
        start_label = entry.start_time ? entry.start_time.strftime('%H:%M') : '--:--'
        finish_label = entry.end_time ? entry.end_time.strftime('%H:%M') : 'running'
        "#{start_label} - #{finish_label}"
      end
    end
  end
end
