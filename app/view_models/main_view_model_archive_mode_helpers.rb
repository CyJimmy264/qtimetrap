# frozen_string_literal: true

module QTimetrap
  module ViewModels
    # Archive-mode specific filtering and projections for MainViewModel.
    module MainViewModelArchiveModeHelpers
      EMPTY_ARRAY = [].freeze

      def project_names
        ['* ALL', *ordered_project_names_for_mode]
      end

      def task_names_for_selected_project
        return [] unless selected_projects == [selected_project]
        return [] if selected_project == '* ALL'

        task_names_for_project(selected_project)
      end

      def task_names_for_project(project)
        normalized_project = normalize_text(project).strip
        return [] if normalized_project.empty? || normalized_project == '* ALL'

        ordered_task_names_by_project.fetch(normalized_project, EMPTY_ARRAY)
      end

      def archive_mode?
        @archive_mode
      end

      def archive_mode=(enabled)
        @archive_mode = [true, 1].include?(enabled)
        reset_archive_mode_caches!
        normalize_selected_projects!
        normalize_selected_tasks!
      end

      def archive_entry(entry_id)
        archived_entries_store.archive(entry_id)
        reset_archive_mode_caches!
      end

      def unarchive_entry(entry_id)
        archived_entries_store.unarchive(entry_id)
        reset_archive_mode_caches!
      end

      private

      def entries_for_mode
        entries.select { |entry| archived_entries_store.archived?(entry.id) == archive_mode? }
      end

      def ordered_project_names_for_mode
        @ordered_project_names_for_mode ||= ordered_project_names(entries_for_mode)
      end

      def ordered_task_names_by_project
        @ordered_task_names_by_project ||= build_ordered_task_names_by_project
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

      def build_ordered_task_names_by_project
        entries_for_mode
          .group_by(&:project)
          .transform_values { |project_entries| ordered_task_names(project_entries) }
      end

      def normalize_selected_projects!
        available = project_names
        normalized = Array(@selected_projects).map(&:to_s).reject(&:empty?).uniq & available
        normalized = ['* ALL'] if normalized.empty? || normalized.include?('* ALL')
        @selected_projects = normalized
        @selected_project = normalized.include?(@selected_project) ? @selected_project : normalized.first
      end

      def reset_archive_mode_caches!
        @ordered_project_names_for_mode = nil
        @ordered_task_names_by_project = nil
      end
    end
  end
end
