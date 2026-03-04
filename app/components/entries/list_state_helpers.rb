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
        @leaf_labels = []
        @entry_rows = []
        @rendering = false
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
        toggle.set_checked(enabled)
        input.set_date_time(value) if enabled
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
          timer.set_single_shot(true)
          timer.set_interval(self.class::TIME_FILTER_DEBOUNCE_MS)
          timer.connect('timeout') { |_| emit_time_range_filter_changed }
        end
      end
    end
  end
end
