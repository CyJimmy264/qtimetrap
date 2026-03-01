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
      include TimetrapGatewayStartHelpers
      include TimetrapGatewayUpdateNoteHelpers
      include TimetrapGatewayQueryHelpers

      def initialize(bin: ENV.fetch('TIMETRAP_BIN', 't'), logger: TimetrapGatewayLogger.new)
        @bin = bin
        @logger = logger
      end

      def entries
        if api_available?
          logger.log_api(operation: 'entries', input: {}, output: 'requested')
          result = entries_from_api
          logger.log_api(operation: 'entries', input: {}, output: { count: result.size })
          return result
        end

        entries_from_cli
      end

      def active_started_at
        if api_available?
          logger.log_api(operation: 'active_started_at', input: {}, output: 'requested')
          result = active_started_at_from_api
          logger.log_api(operation: 'active_started_at', input: {}, output: result&.iso8601)
          return result
        end

        _active, started_at = active_from_cli
        started_at
      end

      def start(sheet, checkin_note = nil)
        normalized_sheet, normalized_checkin_note = normalize_start_inputs(sheet, checkin_note)
        return if normalized_sheet.empty?

        if api_available?
          logger.log_api(
            operation: 'start',
            input: { sheet: normalized_sheet, checkin_note: normalized_checkin_note },
            output: 'requested'
          )
          result = start_via_api(normalized_sheet, normalized_checkin_note)
          logger.log_api(operation: 'start', input: {}, output: result.to_s)
          return result
        end

        start_via_cli(normalized_sheet, normalized_checkin_note)
      end

      def stop
        if api_available?
          logger.log_api(operation: 'stop', input: {}, output: 'requested')
          active = Timetrap::Timer.active_entry
          Timetrap::Timer.stop(active) if active
          logger.log_api(operation: 'stop', input: {}, output: active ? 'stopped' : 'noop')
          return
        end

        run('out')
      end

      private

      def api_available?
        defined?(Timetrap::Entry) && defined?(Timetrap::Timer)
      end

      attr_reader :bin, :logger
    end
  end
end
