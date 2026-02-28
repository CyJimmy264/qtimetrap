# frozen_string_literal: true

module QTimetrap
  module Components
    # Contains main tracking controls, summary labels, and theme actions.
    class TrackerControlsComponent
      attr_reader :task_input, :clock_label, :timer_label, :widget

      def initialize(parent:, on_start:, on_stop:, on_refresh:, on_switch_theme:)
        assign_ui(build_ui(parent:, on_start:, on_stop:, on_refresh:, on_switch_theme:))
      end

      def update_summary(text)
        summary_label.set_text(text)
      end

      def update_project_label(selected_project)
        project_label.set_text("Sheet: #{selected_project[0, 20]}")
      end

      def update_task_input(text)
        task_input.text = text.to_s
      end

      def update_theme_label(theme_name)
        theme_button.set_text("THEME: #{theme_name.upcase}")
      end

      def update_action_button(running:)
        set_visibility(start_button, !running)
        set_visibility(stop_button, running)
      end

      private

      attr_reader :summary_label, :project_label, :theme_button, :start_button, :stop_button

      def build_ui(parent:, on_start:, on_stop:, on_refresh:, on_switch_theme:)
        TrackerControlsLayoutBuilder.new(
          parent: parent,
          on_start: on_start,
          on_stop: on_stop,
          on_refresh: on_refresh,
          on_switch_theme: on_switch_theme
        ).build
      end

      def assign_ui(ui_map)
        @widget = ui_map.fetch(:widget)
        @task_input = ui_map.fetch(:task_input)
        @clock_label = ui_map.fetch(:clock_label)
        @timer_label = ui_map.fetch(:timer_label)
        @summary_label = ui_map.fetch(:summary_label)
        @project_label = ui_map.fetch(:project_label)
        @theme_button = ui_map.fetch(:theme_button)
        @start_button = ui_map.fetch(:start_button)
        @stop_button = ui_map.fetch(:stop_button)
      end

      def set_visibility(button, visible)
        if visible
          button.show if button.respond_to?(:show)
          button.set_visible(1) if button.respond_to?(:set_visible)
        else
          button.hide if button.respond_to?(:hide)
          button.set_visible(0) if button.respond_to?(:set_visible)
        end
      end
    end
  end
end
