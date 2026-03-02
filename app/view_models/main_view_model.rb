# frozen_string_literal: true

require 'date'

module QTimetrap
  module ViewModels
    # Coordinates tracker data and exposes presentation-ready state for UI.
    class MainViewModel
      include MainViewModelEntryNoteHelpers
      include MainViewModelEntryTimeHelpers
      include MainViewModelSheetHelpers
      include MainViewModelTaskFilterHelpers

      EPOCH_TIME = Time.at(0)

      attr_reader :selected_project, :selected_tasks, :entries, :current_started_at, :current_sheet

      def initialize(gateway: Services::TimetrapGateway.new)
        @gateway = gateway
        @selected_project = '* ALL'
        @selected_tasks = []
        @entries = []
        @current_started_at = nil
        @current_sheet = nil
      end

      def refresh!
        @current_started_at = gateway.active_started_at
        @entries = gateway.entries
        @current_sheet = detect_current_sheet
        @selected_project = '* ALL' unless project_names.include?(@selected_project)
        seed_current_fields_from_sheet!
        normalize_selected_tasks!
        self
      end

      def select_project(project)
        @selected_project = project
        @selected_tasks = []
        apply_selected_project_to_current_field!
        self.current_task_input = latest_task_for_project(project)
      end

      def start_tracking(sheet)
        value = normalize_text(sheet).strip
        raise ArgumentError, 'Task is required' if value.empty?

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

      def task_names_for_selected_project
        return [] if selected_project == '* ALL'

        entries
          .select { |entry| entry.project == selected_project }
          .map { |entry| entry.task.to_s }
          .reject(&:empty?)
          .uniq
          .sort
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

      def running_current_sheet?
        !current_started_at.nil?
      end

      def entry_nodes
        EntryNodesBuilder.new(entries: filtered_entries, selected_project: selected_project).build
      end

      private

      attr_reader :gateway

      def detect_current_sheet
        running_sheet || latest_sheet
      end

      def running_sheet
        newest_entry(entries.select(&:running?))&.sheet
      end

      def latest_sheet
        newest_entry(entries)&.sheet
      end

      def newest_entry(collection)
        collection.max_by { |entry| entry.start_time || EPOCH_TIME }
      end

      def latest_task_for_project(project)
        return '' if project == '* ALL'

        entry = newest_entry(entries.select { |item| item.project == project })
        entry ? entry.task.to_s : ''
      end

      def normalize_text(value)
        value.to_s
      end
    end
  end
end
