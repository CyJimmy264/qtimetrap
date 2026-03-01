# frozen_string_literal: true

require 'fileutils'
require 'json'
require 'time'

module QTimetrap
  module Services
    # Writes Timetrap gateway input/output events to local log file.
    class TimetrapGatewayLogger
      DEFAULT_LOG_PATH = File.join(Dir.home, '.local', 'log', 'qtimetrap', 'timetrap_gateway.log')

      def initialize(path: DEFAULT_LOG_PATH)
        @path = path
      end

      def log_cli(bin:, args:, success:, output:)
        write(
          kind: 'cli',
          bin: bin.to_s,
          input: Array(args).map(&:to_s),
          success: success ? true : false,
          output: output.to_s
        )
      end

      def log_api(operation:, input:, output:, success: true)
        write(
          kind: 'api',
          operation: operation.to_s,
          input: input,
          success: success ? true : false,
          output: output
        )
      end

      private

      attr_reader :path

      def write(payload)
        ensure_log_dir!
        line = JSON.generate(payload.merge(at: Time.now.utc.iso8601))
        File.open(path, 'a') { |file| file.puts(line) }
      rescue StandardError
        nil
      end

      def ensure_log_dir!
        FileUtils.mkdir_p(File.dirname(path))
      end
    end
  end
end
