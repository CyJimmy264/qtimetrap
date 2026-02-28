# frozen_string_literal: true

module QTimetrap
  module Components
    class TrackerControlsComponent
      attr_reader :task_input, :clock_label, :timer_label, :widget

      def initialize(parent:, on_start:, on_stop:, on_refresh:, on_switch_theme:)
        @parent = parent
        @on_start = on_start
        @on_stop = on_stop
        @on_refresh = on_refresh
        @on_switch_theme = on_switch_theme

        build
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
      attr_reader :summary_label, :project_label, :theme_button

      def build
        @widget = QWidget.new(parent)
        root = QVBoxLayout.new(widget)
        root.set_contents_margins(0, 8, 0, 0)
        root.set_spacing(14)

        topbar = QWidget.new(widget)
        set_name(topbar, 'topbar')
        topbar_layout = QHBoxLayout.new(topbar)
        topbar_layout.set_contents_margins(16, 8, 16, 8)
        topbar_layout.set_spacing(8)

        title = QLabel.new(topbar)
        set_name(title, 'title_label')
        title.set_text('TIME TRACKER')
        topbar_layout.add_widget(title)
        topbar_layout.add_stretch(1)

        @clock_label = QLabel.new(topbar)
        set_name(clock_label, 'clock_label')
        clock_label.set_alignment(Qt::AlignCenter)
        clock_label.set_fixed_width(220)
        topbar_layout.add_widget(clock_label)
        root.add_widget(topbar)

        tracker_row = QWidget.new(widget)
        set_name(tracker_row, 'tracker_row')
        row_layout = QHBoxLayout.new(tracker_row)
        row_layout.set_contents_margins(14, 12, 14, 12)
        row_layout.set_spacing(8)

        @task_input = QLineEdit.new(tracker_row)
        set_name(task_input, 'task_input')
        task_input.set_placeholder_text('What are you working on?')
        task_input.text = 'gui-clockify'
        row_layout.add_widget(task_input)

        @project_label = QLabel.new(tracker_row)
        set_name(project_label, 'project_label')
        project_label.set_alignment(Qt::AlignCenter)
        project_label.set_fixed_width(150)
        project_label.set_text('Project: ALL')
        row_layout.add_widget(project_label)

        @timer_label = QLabel.new(tracker_row)
        set_name(timer_label, 'timer_label')
        timer_label.set_alignment(Qt::AlignCenter)
        timer_label.set_fixed_width(120)
        timer_label.set_text('00:00:00')
        row_layout.add_widget(timer_label)

        start_button = build_button(tracker_row, 'start_button', 'START', 64, 48)
        stop_button = build_button(tracker_row, 'stop_button', 'STOP', 64, 48)
        row_layout.add_widget(start_button)
        row_layout.add_widget(stop_button)
        root.add_widget(tracker_row)

        actions_row = QWidget.new(widget)
        actions_layout = QHBoxLayout.new(actions_row)
        actions_layout.set_contents_margins(0, 0, 0, 0)
        actions_layout.set_spacing(8)

        @summary_label = QLabel.new(actions_row)
        set_name(summary_label, 'summary_label')
        summary_label.set_alignment(Qt::AlignCenter)
        summary_label.set_fixed_height(42)
        actions_layout.add_widget(summary_label)
        actions_layout.add_stretch(1)

        @theme_button = build_button(actions_row, 'theme_button', 'THEME', 112, 34)
        refresh_button = build_button(actions_row, 'refresh_button', 'REFRESH', 110, 34)
        actions_layout.add_widget(theme_button)
        actions_layout.add_widget(refresh_button)
        root.add_widget(actions_row)

        start_button.connect('clicked') { |_| on_start.call(task_input.text.to_s) }
        stop_button.connect('clicked') { |_| on_stop.call }
        theme_button.connect('clicked') { |_| on_switch_theme.call }
        refresh_button.connect('clicked') { |_| on_refresh.call }
      end

      def build_button(parent, name, text, width, height)
        button = QPushButton.new(parent)
        set_name(button, name)
        button.set_text(text)
        button.set_fixed_width(width)
        button.set_fixed_height(height)
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
