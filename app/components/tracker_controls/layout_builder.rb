# frozen_string_literal: true

module QTimetrap
  module TrackerControls
    # Builds tracker controls widget tree and wires all button callbacks.
    class LayoutBuilder
      include QtUiHelpers
      include LayoutHelpers

      def initialize(parent:, callbacks:)
        @parent = parent
        @callbacks = callbacks
      end

      def build
        @widget = QWidget.new(parent)
        root = build_root_layout
        root.add_widget(build_topbar)
        start_button, stop_button = build_tracker_row(root)
        refresh_button = build_actions_row(root)
        connect_actions(start_button, stop_button, refresh_button)
        ui_payload
      end

      private

      attr_reader :parent, :widget, :callbacks

      def build_topbar
        topbar = QWidget.new(widget)
        topbar.object_name = 'topbar'
        layout = QHBoxLayout.new(topbar)
        configure_topbar_layout(layout, topbar)
        topbar
      end

      def build_tracker_row(root_layout)
        row = QWidget.new(widget)
        row.object_name = 'tracker_row'
        layout = QHBoxLayout.new(row)
        layout.set_contents_margins(14, 12, 14, 12)
        layout.spacing = 8
        start_button, stop_button = add_tracker_row_widgets(layout, row)
        root_layout.add_widget(row)
        [start_button, stop_button]
      end

      def build_actions_row(root_layout)
        row = QWidget.new(widget)
        layout = QHBoxLayout.new(row)
        layout.set_contents_margins(0, 0, 0, 0)
        layout.spacing = 8
        refresh_button = add_actions_row_widgets(layout, row)
        root_layout.add_widget(row)
        refresh_button
      end

      def build_task_input(parent_widget)
        QLineEdit.new(parent_widget).tap do |input|
          input.object_name = 'task_input'
          input.placeholder_text = 'What are you working on?'
          input.focus_policy = Qt::ClickFocus
          input.text = ''
        end
      end

      def build_project_input(parent_widget)
        QLineEdit.new(parent_widget).tap do |input|
          input.object_name = 'project_input'
          input.placeholder_text = 'your project'
          input.focus_policy = Qt::ClickFocus
          input.text = ''
          input.fixed_width = 190
        end
      end

      def connect_actions(start_button, stop_button, refresh_button)
        connect_start_stop(start_button, stop_button)
        connect_theme_refresh(refresh_button)
        connect_project_input
      end

      def connect_start_stop(start_button, stop_button)
        start_button.connect('clicked') do |_|
          callbacks.fetch(:on_start).call(@task_input.text.to_s, @project_input.text.to_s)
        end
        stop_button.connect('clicked') { |_| callbacks.fetch(:on_stop).call }
      end

      def connect_theme_refresh(refresh_button)
        @theme_button.connect('clicked') { |_| callbacks.fetch(:on_switch_theme).call }
        refresh_button.connect('clicked') { |_| callbacks.fetch(:on_refresh).call }
      end

      def connect_project_input
        @project_input.connect('textChanged(QString)') { |text| callbacks.fetch(:on_project_change).call(text.to_s) }
      end
    end
  end
end
