# frozen_string_literal: true

require 'time'

module QTimetrap
  module Models
    # Immutable time tracking entry model used across view and services.
    class TimeEntry
      attr_reader :id, :note, :sheet, :start_time, :end_time

      def initialize(id:, note:, sheet:, start_time:, end_time:)
        @id = id
        @note = note.to_s
        @sheet = sheet.to_s
        @start_time = start_time
        @end_time = end_time
      end

      def running?
        end_time.nil?
      end

      def duration_seconds(now: Time.now)
        return 0 unless start_time

        finish = end_time || now
        [finish.to_i - start_time.to_i, 0].max
      end

      def project
        split_sheet.first
      end

      def task
        split_sheet.last
      end

      def day
        (start_time || Time.now).to_date
      end

      private

      def split_sheet
        raw = sheet.strip
        return ['(default)', '(default task)'] if raw.empty?

        parts = raw.split('|', 2)
        return [raw, '(default task)'] unless parts.size == 2

        project = parts.first.strip
        task = parts.last.strip
        project = '(default)' if project.empty?
        task = '(default task)' if task.empty?
        [project, task]
      end
    end
  end
end
