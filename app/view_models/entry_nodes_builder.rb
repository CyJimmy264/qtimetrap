# frozen_string_literal: true

module QTimetrap
  module ViewModels
    # Builds hierarchical week/day/project/entry nodes for entries list UI.
    class EntryNodesBuilder
      def initialize(entries:, selected_project:)
        @entries = entries
        @selected_project = selected_project
      end

      def build
        nodes = week_groups.map { |week_start, entries| week_node(week_start, entries) }
        nodes.empty? ? [empty_node] : nodes
      end

      private

      attr_reader :entries, :selected_project

      def week_groups
        entries.group_by { |entry| week_start_for(entry.day) }.sort_by { |week_start, _| week_start }.reverse
      end

      def week_node(week_start, week_entries)
        total = Services::Formatters.seconds_to_hms(week_entries.sum(&:duration_seconds))
        week_end = week_start + 6
        {
          id: "week:#{week_start}",
          type: :week,
          label: "Week #{week_start.strftime('%b %-d')} - #{week_end.strftime('%b %-d')}  Total: #{total}",
          children: day_nodes(week_entries)
        }
      end

      def day_nodes(week_entries)
        week_entries.group_by(&:day).keys.sort.reverse.map do |day|
          day_entries = week_entries.select { |entry| entry.day == day }
          total = Services::Formatters.seconds_to_hms(day_entries.sum(&:duration_seconds))
          {
            id: "day:#{day}",
            type: :day,
            label: "#{day.strftime('%a, %b %-d')}  Total: #{total}",
            children: project_nodes(day, day_entries)
          }
        end
      end

      def project_nodes(day, day_entries)
        grouped = day_entries.group_by { |entry| [entry.project, entry.task] }
        grouped
          .sort_by { |_key, items| latest_start_time(items) }
          .reverse
          .map do |(project, task), items|
            total = Services::Formatters.seconds_to_hms(items.sum(&:duration_seconds))
            {
              id: "project:#{day}:#{project}:#{task}",
              type: :project,
              label: "#{project} | #{task} (#{items.size}) #{total}",
              children: entry_detail_nodes(items)
            }
          end
      end

      def entry_detail_nodes(items)
        items.sort_by { |entry| entry.start_time || Time.at(0) }.reverse.each_with_index.map do |entry, index|
          entry_node(entry, index)
        end
      end

      def entry_node(entry, index)
        note = entry.note.strip
        display_note = note.empty? ? '(no note)' : note
        range = Services::Formatters.time_range(entry)
        duration = Services::Formatters.seconds_to_hms(entry.duration_seconds)
        {
          id: "entry:#{entry.id || index}",
          type: :entry,
          entry_id: entry.id || index,
          prefix: "#{range}  #{duration}",
          note: note,
          label: "#{range}  #{duration}  #{display_note}",
          children: []
        }
      end

      def latest_start_time(items)
        items.map { |entry| entry.start_time || Time.at(0) }.max
      end

      def empty_node
        {
          id: "empty:#{selected_project}",
          type: :empty,
          label: "No entries for filter: #{selected_project}",
          children: []
        }
      end

      def week_start_for(day)
        day - ((day.wday + 6) % 7)
      end
    end
  end
end
