# frozen_string_literal: true

module QTimetrap
  module Components
    # Builds tracker controls widget tree and wires all button callbacks.
    class TrackerControlsLayoutBuilder
      def initialize(parent:, on_start:, on_stop:, on_refresh:, on_switch_theme:)
        @parent = parent
        @on_start = on_start
        @on_stop = on_stop
        @on_refresh = on_refresh
        @on_switch_theme = on_switch_theme
      end

      def build
        @widget = QWidget.new(parent)
        root = QVBoxLayout.new(widget)
        root.set_contents_margins(0, 8, 0, 0)
        root.set_spacing(14)
        root.add_widget(build_topbar)
        start_button, stop_button = build_tracker_row(root)
        refresh_button = build_actions_row(root)
        connect_actions(start_button, stop_button, refresh_button)
        ui_payload
      end

      private

      attr_reader :parent, :widget, :on_start, :on_stop, :on_refresh, :on_switch_theme

      def build_topbar
        QWidget.new(widget).tap do |topbar|
          set_name(topbar, 'topbar')
          layout = QHBoxLayout.new(topbar)
          layout.set_contents_margins(16, 8, 16, 8)
          layout.set_spacing(8)
          layout.add_widget(build_label(topbar, 'title_label', 'TIME TRACKER'))
          layout.add_stretch(1)
          @clock_label = build_label(topbar, 'clock_label', nil, width: 220)
          @clock_label.set_alignment(Qt::AlignCenter)
          layout.add_widget(@clock_label)
        end
      end

      def build_tracker_row(root_layout)
        row = QWidget.new(widget)
        set_name(row, 'tracker_row')
        layout = QHBoxLayout.new(row)
        layout.set_contents_margins(14, 12, 14, 12)
        layout.set_spacing(8)

        @task_input = build_task_input(row)
        @project_label = build_label(row, 'project_label', 'Project: ALL', width: 150)
        @project_label.set_alignment(Qt::AlignCenter)
        @timer_label = build_label(row, 'timer_label', '00:00:00', width: 120)
        @timer_label.set_alignment(Qt::AlignCenter)
        start_button = build_button(row, 'start_button', 'START', 64, 48)
        stop_button = build_button(row, 'stop_button', 'STOP', 64, 48)

        [@task_input, @project_label, @timer_label, start_button, stop_button].each { |item| layout.add_widget(item) }
        root_layout.add_widget(row)
        [start_button, stop_button]
      end

      def build_actions_row(root_layout)
        row = QWidget.new(widget)
        layout = QHBoxLayout.new(row)
        layout.set_contents_margins(0, 0, 0, 0)
        layout.set_spacing(8)
        @summary_label = build_label(row, 'summary_label', nil, height: 42)
        @summary_label.set_alignment(Qt::AlignCenter)
        @theme_button = build_button(row, 'theme_button', 'THEME', 112, 34)
        refresh_button = build_button(row, 'refresh_button', 'REFRESH', 110, 34)
        layout.add_widget(@summary_label)
        layout.add_stretch(1)
        layout.add_widget(@theme_button)
        layout.add_widget(refresh_button)
        root_layout.add_widget(row)
        refresh_button
      end

      def build_task_input(parent_widget)
        QLineEdit.new(parent_widget).tap do |input|
          set_name(input, 'task_input')
          input.set_placeholder_text('What are you working on?')
          input.text = 'gui-clockify'
        end
      end

      def build_label(parent_widget, object_name, text, width: nil, height: nil)
        QLabel.new(parent_widget).tap do |label|
          set_name(label, object_name)
          label.set_text(text) if text
          label.set_fixed_width(width) if width
          label.set_fixed_height(height) if height
        end
      end

      def build_button(parent_widget, name, text, width, height)
        QPushButton.new(parent_widget).tap do |button|
          set_name(button, name)
          button.set_text(text)
          button.set_fixed_width(width)
          button.set_fixed_height(height)
        end
      end

      def connect_actions(start_button, stop_button, refresh_button)
        start_button.connect('clicked') { |_| on_start.call(@task_input.text.to_s) }
        stop_button.connect('clicked') { |_| on_stop.call }
        @theme_button.connect('clicked') { |_| on_switch_theme.call }
        refresh_button.connect('clicked') { |_| on_refresh.call }
      end

      def ui_payload
        {
          widget: @widget,
          task_input: @task_input,
          clock_label: @clock_label,
          timer_label: @timer_label,
          summary_label: @summary_label,
          project_label: @project_label,
          theme_button: @theme_button
        }
      end

      def set_name(target, value)
        if target.respond_to?(:set_object_name)
          target.set_object_name(value)
        elsif target.respond_to?(:setObjectName)
          target.setObjectName(value)
        end
      end
    end
  end
end
