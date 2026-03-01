# frozen_string_literal: true

module QTimetrap
  module Services
    # Query/run helpers for TimetrapGateway CLI and API data reads.
    module TimetrapGatewayQueryHelpers
      private

      def entries_from_api
        Timetrap::Entry.order(:start).all.map do |entry|
          Models::TimeEntry.new(
            id: entry.id,
            note: entry.note,
            sheet: entry.sheet,
            start_time: entry[:start],
            end_time: entry[:end]
          )
        end
      end

      def entries_from_cli
        ok, output = run('display', '--format', 'json')
        return [] unless ok

        output = normalize_text(output)
        rows = parse_rows(output)
        return [] unless rows

        rows.map { |row| build_entry(row) }
      rescue JSON::ParserError
        []
      end

      def active_started_at_from_api
        active = Timetrap::Timer.active_entry
        active ? active[:start] : nil
      end

      def active_from_cli
        ok, output = run('now')
        return [nil, nil] unless ok

        output = normalize_text(output)
        match = output.match(/(\d{4}-\d{2}-\d{2} [0-9:]+ [+-]\d{4})/)
        [true, (match ? parse_time(match[1]) : nil)]
      end

      def run(*args)
        normalized_args = normalize_command_args(args)
        output, status = Open3.capture2e(bin, *normalized_args)
        log_cli_result(args: normalized_args, success: status.success?, output: output)
      rescue Errno::ENOENT
        log_cli_result(args: args, success: false, output: "Command not found: #{bin}")
      rescue StandardError => e
        log_cli_result(args: args, success: false, output: "#{e.class}: #{e.message}")
      end

      def normalize_command_args(args)
        args.map { |arg| arg.is_a?(String) ? normalize_text(arg) : arg }
      end

      def log_cli_result(args:, success:, output:)
        normalized_output = normalize_text(output)
        logger.log_cli(bin: bin, args: args, success: success, output: normalized_output)
        [success, normalized_output]
      end

      def parse_time(value)
        Time.parse(value)
      rescue ArgumentError, TypeError
        nil
      end

      def parse_rows(output)
        rows = JSON.parse(output)
        rows.is_a?(Array) ? rows : nil
      end

      def build_entry(row)
        Models::TimeEntry.new(
          id: row['id'],
          note: row['note'],
          sheet: row['sheet'],
          start_time: parse_time(row['start']),
          end_time: parse_time(row['end'])
        )
      end

      def normalize_text(value)
        value.to_s.encode('UTF-8', invalid: :replace, undef: :replace, replace: '').scrub('')
      end
    end
  end
end
