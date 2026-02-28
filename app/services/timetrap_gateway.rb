# frozen_string_literal: true

require 'json'
require 'open3'

begin
  require 'timetrap'
rescue LoadError
  # CLI fallback is supported.
end

module QTimetrap
  module Services
    # Integrates with Timetrap via Ruby API or CLI fallback.
    class TimetrapGateway
      def initialize(bin: ENV.fetch('TIMETRAP_BIN', 't'))
        @bin = bin
      end

      def entries
        api_available? ? entries_from_api : entries_from_cli
      end

      def active_started_at
        return active_started_at_from_api if api_available?

        _active, started_at = active_from_cli
        started_at
      end

      def start(note)
        return Timetrap::Timer.start(note) if api_available?

        run('in', note)
      end

      def stop
        if api_available?
          active = Timetrap::Timer.active_entry
          Timetrap::Timer.stop(active) if active
          return
        end

        run('out')
      end

      private

      def api_available?
        defined?(Timetrap::Entry) && defined?(Timetrap::Timer)
      end

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

        match = output.match(/(\d{4}-\d{2}-\d{2} [0-9:]+ [+-]\d{4})/)
        [true, (match ? parse_time(match[1]) : nil)]
      end

      def run(*args)
        output, status = Open3.capture2e(bin, *args)
        [status.success?, output]
      rescue Errno::ENOENT
        [false, "Command not found: #{bin}"]
      rescue StandardError => e
        [false, "#{e.class}: #{e.message}"]
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

      attr_reader :bin
    end
  end
end
