# frozen_string_literal: true

module QTimetrap
  module Components
    # Contains main tracking controls, summary labels, and theme actions.
    class TrackerControlsComponent
      attr_reader :task_input, :project_input, :clock_label, :timer_label, :widget

      def initialize(parent:, callbacks:)
        assign_ui(build_ui(parent:, callbacks:))
      end

      def update_summary(text)
        summary_label.set_text(text)
      end

      def update_project_input(project_name)
        value = project_name.to_s.strip
        project_input.set_text(value)
      end

      def update_task_input(text)
        task_input.text = text.to_s
      end

      def update_theme_label(theme_name)
        theme_button.set_text("THEME: #{theme_name.upcase}")
      end

      def update_action_button(running:)
        start_button.set_visible(!running)
        stop_button.set_visible(running)
      end

      private

      attr_reader :summary_label, :theme_button, :start_button, :stop_button

      def build_ui(parent:, callbacks:)
        TrackerControlsLayoutBuilder.new(
          parent: parent,
          callbacks: callbacks
        ).build
      end

      def assign_ui(ui_map)
        @widget = ui_map.fetch(:widget)
        @task_input = ui_map.fetch(:task_input)
        @clock_label = ui_map.fetch(:clock_label)
        @timer_label = ui_map.fetch(:timer_label)
        @summary_label = ui_map.fetch(:summary_label)
        @project_input = ui_map.fetch(:project_input)
        @theme_button = ui_map.fetch(:theme_button)
        @start_button = ui_map.fetch(:start_button)
        @stop_button = ui_map.fetch(:stop_button)
      end
    end
  end
end
