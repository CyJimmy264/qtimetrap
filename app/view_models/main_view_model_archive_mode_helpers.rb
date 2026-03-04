# frozen_string_literal: true

module QTimetrap
  module ViewModels
    # Archive-mode specific filtering and projections for MainViewModel.
    module MainViewModelArchiveModeHelpers
      def project_names
        ['* ALL', *entries_for_mode.map(&:project).uniq.sort]
      end

      def task_names_for_selected_project
        return [] if selected_project == '* ALL'

        entries_for_mode
          .select { |entry| entry.project == selected_project }
          .map { |entry| entry.task.to_s }
          .reject(&:empty?)
          .uniq
          .sort
      end

      def archive_mode?
        @archive_mode
      end

      def archive_mode=(enabled)
        @archive_mode = [true, 1].include?(enabled)
        @selected_project = '* ALL' unless project_names.include?(@selected_project)
        normalize_selected_tasks!
      end

      private

      def entries_for_mode
        entries.select { |entry| archived_entries_store.archived?(entry.id) == archive_mode? }
      end
    end
  end
end
