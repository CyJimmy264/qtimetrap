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
        project_label.set_text("Project: #{selected_project[0, 20]}")
      end

      def update_theme_label(theme_name)
        theme_button.set_text("THEME: #{theme_name.upcase}")
      end

      private

      attr_reader :summary_label, :project_label, :theme_button

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
      end
    end
  end
end
