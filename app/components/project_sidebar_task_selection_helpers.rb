# frozen_string_literal: true

module QTimetrap
  module Components
    # Selection state behavior for sidebar task shortcuts.
    module ProjectSidebarTaskSelectionHelpers
      private

      def refresh_task_state(values, selected_task)
        values_changed = task_values != values
        @task_values = values.dup
        return normalize_task_selection unless values_changed

        @selected_task_indices = []
        @last_task_anchor_index = nil
        return unless selected_task

        index = values.index(selected_task)
        return unless index

        @selected_task_indices = [index]
        @last_task_anchor_index = index
      end

      def clear_task_state
        @task_values = []
        @selected_task_indices = []
        @last_task_anchor_index = nil
      end

      def normalize_task_selection
        max_index = task_values.length - 1
        @selected_task_indices = selected_task_indices.select { |index| index <= max_index }
        @last_task_anchor_index = nil unless selected_task_indices.include?(last_task_anchor_index)
      end

      def apply_task_selection(index)
        ctrl, shift = selection_modifiers
        if shift && !last_task_anchor_index.nil?
          apply_shift_selection(index, ctrl: ctrl)
        elsif ctrl
          toggle_task_index(index)
        else
          @selected_task_indices = [index]
        end
        @last_task_anchor_index = index
      end

      def selection_modifiers
        modifiers = QApplication.keyboard_modifiers.to_i
        ctrl = modifiers.anybits?(Qt::ControlModifier)
        shift = modifiers.anybits?(Qt::ShiftModifier)
        [ctrl, shift]
      end

      def apply_shift_selection(index, ctrl:)
        first = [last_task_anchor_index, index].min
        last = [last_task_anchor_index, index].max
        range = (first..last).to_a
        @selected_task_indices = ctrl ? (selected_task_indices | range) : range
      end

      def toggle_task_index(index)
        @selected_task_indices = if selected_task_indices.include?(index)
                                   selected_task_indices - [index]
                                 else
                                   selected_task_indices + [index]
                                 end
      end
    end
  end
end
