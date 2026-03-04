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
        scoped = if selected_project == '* ALL'
                   entries_for_mode
                 else
                   entries_for_mode.select do |entry|
                     entry.project == selected_project
                   end
                 end
        scoped = scoped.select { |entry| selected_tasks.include?(entry.task.to_s) } unless selected_tasks.empty?
        return scoped if @time_filter_from_at.nil? && @time_filter_to_at.nil?

        scoped.select { |entry| entry_in_selected_time_range?(entry) }
      end

      private

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
