# frozen_string_literal: true

module QTimetrap
  module Components
    class TrackerControlsComponent
      attr_reader :task_input, :clock_label, :timer_label

      def initialize(parent:, x:, y:, width:, on_start:, on_stop:, on_refresh:, on_switch_theme:)
        @parent = parent
        @on_start = on_start
        @on_stop = on_stop
        @on_refresh = on_refresh
        @on_switch_theme = on_switch_theme

        build
        relayout(x: x, y: y, width: width)
      end

      def relayout(x:, y:, width:)
        topbar.set_geometry(x, y + 8, width, 56)
        title.set_geometry(x + 16, y + 16, 400, 36)
        clock_label.set_geometry(x + width - 240, y + 16, 220, 36)

        tracker_row.set_geometry(x, y + 78, width, 74)
        task_input.set_geometry(x + 14, y + 91, width - 470, 48)
        project_label.set_geometry(x + width - 440, y + 91, 150, 48)
        timer_label.set_geometry(x + width - 280, y + 91, 120, 48)

        start_button.set_geometry(x + width - 152, y + 91, 64, 48)
        stop_button.set_geometry(x + width - 80, y + 91, 64, 48)

        summary_label.set_geometry(x, y + 164, width - 252, 42)
        theme_button.set_geometry(x + width - 244, y + 168, 112, 34)
        refresh_button.set_geometry(x + width - 124, y + 168, 110, 34)
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

      attr_reader :parent, :on_start, :on_stop, :on_refresh, :on_switch_theme
      attr_reader :topbar, :title, :tracker_row, :project_label, :summary_label
      attr_reader :theme_button, :refresh_button, :start_button, :stop_button

      def build
        @topbar = QLabel.new(parent)
        set_name(topbar, 'topbar')

        @title = QLabel.new(parent)
        set_name(title, 'title_label')
        title.set_alignment(Qt::AlignCenter)
        title.set_text('TIME TRACKER')

        @clock_label = QLabel.new(parent)
        set_name(clock_label, 'clock_label')
        clock_label.set_alignment(Qt::AlignCenter)

        @tracker_row = QLabel.new(parent)
        set_name(tracker_row, 'tracker_row')

        @task_input = QLineEdit.new(parent)
        set_name(task_input, 'task_input')
        task_input.set_placeholder_text('What are you working on?')
        task_input.text = 'gui-clockify'

        @project_label = QLabel.new(parent)
        set_name(project_label, 'project_label')
        project_label.set_alignment(Qt::AlignCenter)
        project_label.set_text('Project: ALL')

        @timer_label = QLabel.new(parent)
        set_name(timer_label, 'timer_label')
        timer_label.set_alignment(Qt::AlignCenter)
        timer_label.set_text('00:00:00')

        @start_button = build_button('start_button', 'START')
        @stop_button = build_button('stop_button', 'STOP')
        @theme_button = build_button('theme_button', 'THEME')
        @refresh_button = build_button('refresh_button', 'REFRESH')

        @summary_label = QLabel.new(parent)
        set_name(summary_label, 'summary_label')
        summary_label.set_alignment(Qt::AlignCenter)

        start_button.connect('clicked') { |_| on_start.call(task_input.text.to_s) }
        stop_button.connect('clicked') { |_| on_stop.call }
        theme_button.connect('clicked') { |_| on_switch_theme.call }
        refresh_button.connect('clicked') { |_| on_refresh.call }
      end

      def build_button(name, text)
        button = QPushButton.new(parent)
        set_name(button, name)
        button.set_text(text)
        button
      end

      def set_name(widget, value)
        if widget.respond_to?(:set_object_name)
          widget.set_object_name(value)
        elsif widget.respond_to?(:setObjectName)
          widget.setObjectName(value)
        end
      end
    end
  end
end
