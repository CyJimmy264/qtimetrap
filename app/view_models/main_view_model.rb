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

      def entry_nodes
        EntryNodesBuilder.new(entries: filtered_entries, selected_project: selected_project).build
      end

      private

      attr_reader :gateway
    end
  end
end
