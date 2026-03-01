# frozen_string_literal: true

module QTimetrap
  module ViewModels
    # Task filter behavior for MainViewModel.
    module MainViewModelTaskFilterHelpers
      def select_tasks(tasks)
        normalized = Array(tasks).map(&:to_s).reject(&:empty?).uniq
        @selected_tasks = selected_project == '* ALL' ? [] : (normalized & task_names_for_selected_project)
      end

      def filtered_entries
        scoped = selected_project == '* ALL' ? entries : entries.select { |entry| entry.project == selected_project }
        return scoped if selected_tasks.empty?

        scoped.select { |entry| selected_tasks.include?(entry.task.to_s) }
      end

      private

      def normalize_selected_tasks!
        return @selected_tasks = [] if selected_project == '* ALL'

        @selected_tasks &= task_names_for_selected_project
      end
    end
  end
end
