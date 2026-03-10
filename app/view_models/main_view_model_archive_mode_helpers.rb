# frozen_string_literal: true

module QTimetrap
  module ViewModels
    # Archive-mode specific filtering and projections for MainViewModel.
    module MainViewModelArchiveModeHelpers
      def project_names
        ['* ALL', *ordered_project_names(entries_for_mode)]
      end

      def task_names_for_selected_project
        return [] unless selected_projects == [selected_project]
        return [] if selected_project == '* ALL'

        ordered_task_names(entries_for_mode.select { |entry| entry.project == selected_project })
      end

      def archive_mode?
        @archive_mode
      end

      def archive_mode=(enabled)
        @archive_mode = [true, 1].include?(enabled)
        normalize_selected_projects!
        normalize_selected_tasks!
      end

      private

      def entries_for_mode
        entries.select { |entry| archived_entries_store.archived?(entry.id) == archive_mode? }
      end

      def ordered_project_names(collection)
        collection
          .group_by(&:project)
          .sort_by { |project, project_entries| sort_key(project, project_entries) }
          .map(&:first)
      end

      def ordered_task_names(collection)
        collection
          .group_by { |entry| entry.task.to_s }
          .reject { |task, _| task.empty? }
          .sort_by { |task, task_entries| sort_key(task, task_entries) }
          .map(&:first)
      end

      def sort_key(name, grouped_entries)
        newest_started_at = newest_entry(grouped_entries)&.start_time || EPOCH_TIME
        [-newest_started_at.to_i, name]
      end

      def normalize_selected_projects!
        available = project_names
        normalized = Array(@selected_projects).map(&:to_s).reject(&:empty?).uniq & available
        normalized = ['* ALL'] if normalized.empty? || normalized.include?('* ALL')
        @selected_projects = normalized
        @selected_project = normalized.include?(@selected_project) ? @selected_project : normalized.first
      end
    end
  end
end
