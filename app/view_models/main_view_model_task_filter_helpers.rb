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
        scoped = entries_for_selected_project
        scoped = apply_selected_tasks_filter(scoped)
        apply_time_range_filter(scoped)
      end

      private

      def entries_for_selected_project
        return entries_for_mode if selected_project == '* ALL'

        entries_for_mode.select { |entry| entry.project == selected_project }
      end

      def apply_selected_tasks_filter(scoped)
        return scoped if selected_tasks.empty?

        scoped.select { |entry| selected_tasks.include?(entry.task.to_s) }
      end

      def apply_time_range_filter(scoped)
        return scoped if @time_filter_from_at.nil? && @time_filter_to_at.nil?

        scoped.select { |entry| entry_in_selected_time_range?(entry) }
      end

      def entry_in_selected_time_range?(entry)
        start_at = entry.start_time
        return false unless start_at
        return false if @time_filter_from_at && start_at < @time_filter_from_at
        return false if @time_filter_to_at && start_at > @time_filter_to_at

        true
      end

      def normalize_selected_tasks!
        return @selected_tasks = [] if selected_project == '* ALL'

        @selected_tasks &= task_names_for_selected_project
      end
    end
  end
end
