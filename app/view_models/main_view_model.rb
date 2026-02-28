# frozen_string_literal: true

require 'date'

module QTimetrap
  module ViewModels
    # Coordinates tracker data and exposes presentation-ready state for UI.
    class MainViewModel
      attr_reader :selected_project, :entries, :current_started_at

      def initialize(gateway: Services::TimetrapGateway.new)
        @gateway = gateway
        @selected_project = '* ALL'
        @entries = []
        @current_started_at = nil
      end

      def refresh!
        @current_started_at = gateway.active_started_at
        @entries = gateway.entries
        @selected_project = '* ALL' unless project_names.include?(@selected_project)
        self
      end

      def select_project(project)
        @selected_project = project
      end

      def start_tracking(note)
        value = note.to_s.strip
        value = 'gui-clockify' if value.empty?
        gateway.start(value)
        @current_started_at = Time.now unless current_started_at
      end

      def stop_tracking
        gateway.stop
        @current_started_at = nil
      end

      def project_names
        ['* ALL', *entries.map(&:project).uniq.sort]
      end

      def filtered_entries
        return entries if selected_project == '* ALL'

        entries.select { |entry| entry.project == selected_project }
      end

      def week_total_seconds
        start_of_week = Date.today - ((Date.today.wday + 6) % 7)
        filtered_entries.sum do |entry|
          entry.day >= start_of_week ? entry.duration_seconds : 0
        end
      end

      def total_seconds
        filtered_entries.sum(&:duration_seconds)
      end

      def summary_line
        "Week total: #{Services::Formatters.seconds_to_hms(week_total_seconds)} | " \
          "Total: #{Services::Formatters.seconds_to_hms(total_seconds)}"
      end

      def running_timer_line(now: Time.now)
        return '00:00:00' unless current_started_at

        Services::Formatters.seconds_to_hms(now.to_i - current_started_at.to_i)
      end

      def grouped_lines
        rows = filtered_entries.group_by(&:day)
                               .keys
                               .sort
                               .reverse
                               .flat_map { |day| day_rows(day) }
        rows.empty? ? ["No entries for filter: #{selected_project}"] : rows
      end

      private

      attr_reader :gateway

      def day_rows(day)
        day_entries = filtered_entries.select { |entry| entry.day == day }
        [day_header(day, day_entries), *project_rows(day_entries)]
      end

      def day_header(day, day_entries)
        total = Services::Formatters.seconds_to_hms(day_entries.sum(&:duration_seconds))
        "#{day.strftime('%a, %b %-d')}  Total: #{total}"
      end

      def project_rows(day_entries)
        day_entries.group_by { |entry| [entry.project, entry.task] }.flat_map do |(project, task), items|
          [project_header(project, task, items), *detail_rows(items)]
        end
      end

      def project_header(project, task, items)
        total = Services::Formatters.seconds_to_hms(items.sum(&:duration_seconds))
        "  #{project} | #{task} (#{items.size}) #{total}"
      end

      def detail_rows(entries)
        entries.sort_by { |entry| entry.start_time || Time.at(0) }
               .reverse
               .map { |entry| detail_row(entry) }
      end

      def detail_row(entry)
        note = entry.note.strip
        note = '(no note)' if note.empty?
        range = Services::Formatters.time_range(entry)
        duration = Services::Formatters.seconds_to_hms(entry.duration_seconds)
        "    #{range}  #{duration}  #{note}"
      end
    end
  end
end
