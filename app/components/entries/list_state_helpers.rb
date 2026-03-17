# frozen_string_literal: true

module QTimetrap
  module Entries
    # Internal state and debounce helpers for entries list component.
    module ListStateHelpers
      private

      def initialize_state!
        initialize_tree_state!
        initialize_time_filter_state!
      end

      def initialize_tree_state!
        @expanded = {}
        @current_nodes = []
        @branch_bindings = {}
        initialize_task_editor_state!
        @active_task_container_key = nil
        @leaf_labels = []
        @entry_rows = []
        @rendering = false
      end

      def initialize_task_editor_state!
        @task_containers = {}
        @task_display_inputs = {}
        @task_editors = {}
        @task_editor_line_edits = {}
      end

      def initialize_time_filter_state!
        @time_filter_from_toggle = nil
        @time_filter_to_toggle = nil
        @time_filter_from_input = nil
        @time_filter_to_input = nil
        @time_filter_debounce = nil
        @syncing_time_filters = false
      end

      def set_time_filter_state(toggle:, input:, value:)
        enabled = !value.nil?
        toggle.checked = enabled
        input.date_time = value if enabled
      end

      def syncing_time_filters?
        @syncing_time_filters
      end

      def schedule_time_range_filter_changed
        return if syncing_time_filters?
        return unless on_time_range_change

        time_filter_debounce.stop if time_filter_debounce.is_active
        time_filter_debounce.start
      end

      def build_time_filter_debounce_timer
        QTimer.new(parent).tap do |timer|
          timer.single_shot = true
          timer.interval = self.class::TIME_FILTER_DEBOUNCE_MS
          timer.connect('timeout') { |_| emit_time_range_filter_changed }
        end
      end

      def register_task_widgets(task_container, display_input, editor, line_edit)
        container_key = task_container_key(task_container)
        task_containers[container_key] = task_container
        task_display_inputs[container_key] = display_input
        task_editors[container_key] = editor
        task_editor_line_edits[task_editor_key(editor)] = line_edit
      end

      def task_container_key(task_container)
        task_container.handle.address
      end

      def task_editor_key(editor)
        editor.handle.address
      end

      def task_container_matches?(left, right)
        task_container_key(left) == task_container_key(right)
      end

      def task_container_for_key(key)
        task_containers[key]
      end

      def active_task_container
        task_container_for_key(active_task_container_key)
      end

      def active_task_container=(task_container)
        @active_task_container_key = task_container ? task_container_key(task_container) : nil
      end

      def task_display_input_for(task_container)
        task_display_inputs[task_container_key(task_container)]
      end

      def task_editor_for(task_container)
        task_editors[task_container_key(task_container)]
      end

      def task_editor_line_edit_for(editor)
        task_editor_line_edits[task_editor_key(editor)]
      end

      attr_reader :task_containers, :task_display_inputs, :task_editors, :task_editor_line_edits,
                  :active_task_container_key
    end
  end
end
