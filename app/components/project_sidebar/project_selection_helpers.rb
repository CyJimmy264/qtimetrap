# frozen_string_literal: true

module QTimetrap
  module ProjectSidebar
    # Selection state behavior for sidebar project shortcuts.
    module ProjectSelectionHelpers
      private

      def refresh_project_state(values, selected_projects, selected_project)
        values_changed = project_values != values
        @project_values = values.dup
        return normalize_project_selection(selected_project) unless values_changed

        @selected_project_indices = []
        @last_project_anchor_index = nil
        normalized = normalize_selected_projects(values, selected_projects, selected_project)
        @selected_project_indices = normalized.filter_map { |project| values.index(project) }
        @last_project_anchor_index = values.index(selected_project) || selected_project_indices.last
      end

      def normalize_project_selection(selected_project)
        max_index = project_values.length - 1
        @selected_project_indices = selected_project_indices.select { |index| index <= max_index }
        normalized = normalize_selected_projects(project_values, selected_project_values, selected_project)
        @selected_project_indices = normalized.filter_map { |project| project_values.index(project) }
        @last_project_anchor_index = project_values.index(selected_project) || selected_project_indices.last
      end

      def apply_project_selection(index)
        ctrl, shift = selection_modifiers
        if shift && !last_project_anchor_index.nil?
          apply_project_shift_selection(index, ctrl: ctrl)
        elsif ctrl
          toggle_project_index(index)
        else
          @selected_project_indices = [index]
        end

        @last_project_anchor_index = index
        normalize_project_all_selection
      end

      def apply_project_shift_selection(index, ctrl:)
        first = [last_project_anchor_index, index].min
        last = [last_project_anchor_index, index].max
        range = (first..last).to_a
        @selected_project_indices = ctrl ? (selected_project_indices | range) : range
      end

      def toggle_project_index(index)
        @selected_project_indices = if selected_project_indices.include?(index)
                                      selected_project_indices - [index]
                                    else
                                      selected_project_indices + [index]
                                    end
      end

      def normalize_project_all_selection
        all_index = project_values.index('* ALL')
        return unless all_index
        return @selected_project_indices = [all_index] if selected_project_indices.empty?
        return unless selected_project_indices.include?(all_index) && selected_project_indices.length > 1

        @selected_project_indices = [last_project_anchor_index == all_index ? all_index : last_project_anchor_index]
      end

      def normalize_selected_projects(values, selected_projects, selected_project)
        normalized = Array(selected_projects).map(&:to_s).reject(&:empty?).uniq
        normalized = [selected_project.to_s] if normalized.empty? && !selected_project.to_s.empty?
        normalized &= values
        normalized = ['* ALL'] if normalized.empty? || normalized.include?('* ALL')
        normalized
      end

      def selected_project_values
        selected_project_indices.filter_map { |index| project_values[index] }
      end

      attr_reader :selected_project_indices, :last_project_anchor_index, :project_values
    end
  end
end
