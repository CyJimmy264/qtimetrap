# frozen_string_literal: true

module QTimetrap
  module Components
    # Builds tracker controls widget tree and wires all button callbacks.
    class TrackerControlsLayoutBuilder
      include QtUiHelpers
      include TrackerControlsLayoutHelpers

      def initialize(parent:, on_start:, on_stop:, on_refresh:, on_switch_theme:)
        @parent = parent
        @on_start = on_start
        @on_stop = on_stop
        @on_refresh = on_refresh
        @on_switch_theme = on_switch_theme
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

      attr_reader :parent, :widget, :on_start, :on_stop, :on_refresh, :on_switch_theme

      def build_topbar
        topbar = QWidget.new(widget)
        set_name(topbar, 'topbar')
        layout = QHBoxLayout.new(topbar)
        configure_topbar_layout(layout, topbar)
        topbar
      end

      def build_tracker_row(root_layout)
        row = QWidget.new(widget)
        set_name(row, 'tracker_row')
        layout = QHBoxLayout.new(row)
        layout.set_contents_margins(14, 12, 14, 12)
        layout.set_spacing(8)
        start_button, stop_button = add_tracker_row_widgets(layout, row)
        root_layout.add_widget(row)
        [start_button, stop_button]
      end

      def build_actions_row(root_layout)
        row = QWidget.new(widget)
        layout = QHBoxLayout.new(row)
        layout.set_contents_margins(0, 0, 0, 0)
        layout.set_spacing(8)
        refresh_button = add_actions_row_widgets(layout, row)
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

      def connect_actions(start_button, stop_button, refresh_button)
        start_button.connect('clicked') { |_| on_start.call(@task_input.text.to_s) }
        stop_button.connect('clicked') { |_| on_stop.call }
        @theme_button.connect('clicked') { |_| on_switch_theme.call }
        refresh_button.connect('clicked') { |_| on_refresh.call }
      end
    end
  end
end
