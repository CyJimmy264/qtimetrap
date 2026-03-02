# frozen_string_literal: true

module QTimetrap
  module Services
    # Time bounds update workflow for Timetrap API/CLI adapters.
    module TimetrapGatewayUpdateTimeHelpers
      def update_time(entry_id, start_time:, end_time:)
        normalized_id = entry_id.to_i
        return if normalized_id.zero?

        if api_available?
          logger.log_api(
            operation: 'update_time',
            input: {
              entry_id: normalized_id,
              start_time: start_time&.iso8601,
              end_time: end_time&.iso8601
            },
            output: 'requested'
          )
          result = update_time_via_api(normalized_id, start_time: start_time, end_time: end_time)
          logger.log_api(operation: 'update_time', input: {}, output: result.to_s)
          return result
        end

        update_time_via_cli(normalized_id, start_time: start_time, end_time: end_time)
      end

      private

      def update_time_via_api(entry_id, start_time:, end_time:)
        entry = resolve_entry_for_note_update(Timetrap::Entry[entry_id])
        entry.start = start_time if start_time
        entry.end = end_time if end_time
        entry.save
      end

      def update_time_via_cli(entry_id, start_time:, end_time:)
        args = ['edit', '--id', entry_id.to_s]
        args += ['--start', format_cli_timestamp(start_time)] if start_time
        args += ['--end', format_cli_timestamp(end_time)] if end_time
        run(*args)
      end

      def format_cli_timestamp(time)
        time.strftime('%Y-%m-%d %H:%M:%S %z')
      end
    end
  end
end
