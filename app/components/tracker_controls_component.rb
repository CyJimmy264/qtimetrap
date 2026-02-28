# frozen_string_literal: true

module QTimetrap
  module Components
    # Contains main tracking controls, summary labels, and theme actions.
    class TrackerControlsComponent
      attr_reader :task_input, :clock_label, :timer_label, :widget

      def initialize(parent:, on_start:, on_stop:, on_refresh:, on_switch_theme:)
        ui = TrackerControlsLayoutBuilder.new(
          parent: parent,
          on_start: on_start,
          on_stop: on_stop,
          on_refresh: on_refresh,
          on_switch_theme: on_switch_theme
        ).build
        @widget = ui.fetch(:widget)
        @task_input = ui.fetch(:task_input)
        @clock_label = ui.fetch(:clock_label)
        @timer_label = ui.fetch(:timer_label)
        @summary_label = ui.fetch(:summary_label)
        @project_label = ui.fetch(:project_label)
        @theme_button = ui.fetch(:theme_button)
      end

      def update_summary(text)
        summary_label.set_text(text)
      end

      def update_project_label(selected_project)
        project_label.set_text("Project: #{selected_project[0, 20]}")
      end

      def update_theme_label(theme_name)
        theme_button.set_text("THEME: #{theme_name.upcase}")
      end

      private

      attr_reader :summary_label, :project_label, :theme_button
    end
  end
end
