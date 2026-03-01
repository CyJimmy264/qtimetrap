# frozen_string_literal: true

module QTimetrap
  module Components
    # Extracted helper methods for tracker controls layout assembly.
    module TrackerControlsLayoutHelpers
      TITLE_SLOGANS = [
        'Track time, ship value',
        'Small steps, big output',
        'Focus. Build. Finish.',
        'Consistency beats intensity',
        "Today's minutes, tomorrow's results",
        'Make progress visible',
        'Do the next right task'
      ].freeze

      private

      def build_root_layout
        QVBoxLayout.new(widget).tap do |layout|
          layout.set_contents_margins(0, 8, 0, 0)
          layout.set_spacing(14)
        end
      end

      def configure_topbar_layout(layout, topbar)
        layout.set_contents_margins(16, 8, 16, 8)
        layout.set_spacing(8)
        layout.add_widget(build_label(topbar, 'title_label', random_title_slogan))
        layout.add_stretch(1)
        @clock_label = build_label(topbar, 'clock_label', nil, width: 220)
        @clock_label.set_alignment(Qt::AlignCenter)
        layout.add_widget(@clock_label)
      end

      def add_tracker_row_widgets(layout, row)
        @task_input = build_task_input(row)
        @project_input = build_project_input(row)
        @timer_label = build_label(row, 'timer_label', '00:00:00', width: 120)
        @timer_label.set_alignment(Qt::AlignCenter)
        @start_button = build_button(row, 'start_button', 'START', 64, 48)
        @stop_button = build_button(row, 'stop_button', 'STOP', 64, 48)
        @stop_button.hide
        [@task_input, @project_input, @timer_label, @start_button, @stop_button].each { |item| layout.add_widget(item) }
        [@start_button, @stop_button]
      end

      def add_actions_row_widgets(layout, row)
        @summary_label = build_label(row, 'summary_label', nil, height: 42)
        @summary_label.set_alignment(Qt::AlignCenter)
        @theme_button = build_button(row, 'theme_button', 'THEME', 112, 34)
        refresh_button = build_button(row, 'refresh_button', 'REFRESH', 110, 34)
        layout.add_widget(@summary_label)
        layout.add_stretch(1)
        layout.add_widget(@theme_button)
        layout.add_widget(refresh_button)
        refresh_button
      end

      def ui_payload
        ui_core_payload.merge(ui_controls_payload)
      end

      def ui_core_payload
        {
          widget: @widget,
          task_input: @task_input,
          clock_label: @clock_label,
          timer_label: @timer_label
        }
      end

      def ui_controls_payload
        {
          summary_label: @summary_label,
          project_input: @project_input,
          theme_button: @theme_button,
          start_button: @start_button,
          stop_button: @stop_button
        }
      end

      def random_title_slogan
        TITLE_SLOGANS.sample
      end
    end
  end
end
