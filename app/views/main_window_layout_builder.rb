# frozen_string_literal: true

module QTimetrap
  module Views
    # Builds main window layout and returns initialized component instances.
    class MainWindowLayoutBuilder
      SIDEBAR_WIDTH = 220

      def initialize(window:, callbacks:)
        @window = window
        @callbacks = callbacks
      end

      def build
        root = QHBoxLayout.new(window)
        root.set_contents_margins(0, 0, 0, 0)
        root.set_spacing(0)
        sidebar = build_sidebar
        content, controls, entries = build_content
        root.add_widget(sidebar.widget)
        root.add_widget(content)
        root.set_stretch(1, 1)
        { sidebar: sidebar, controls: controls, entries: entries }
      end

      private

      attr_reader :window, :callbacks

      def build_sidebar
        Components::ProjectSidebarComponent.new(
          parent: window,
          on_project_selected: callbacks.fetch(:on_project_selected)
        ).tap { |component| component.widget.set_fixed_width(SIDEBAR_WIDTH) }
      end

      def build_content
        content, layout = build_content_widget
        controls = build_controls(content)
        entries = Components::EntriesListComponent.new(parent: content)
        layout.add_widget(controls.widget)
        layout.add_widget(entries.widget)
        layout.set_stretch(1, 1)
        [content, controls, entries]
      end

      def build_content_widget
        content = QWidget.new(window)
        layout = QVBoxLayout.new(content)
        layout.set_contents_margins(14, 8, 14, 8)
        layout.set_spacing(10)
        [content, layout]
      end

      def build_controls(content)
        Components::TrackerControlsComponent.new(
          parent: content,
          on_start: callbacks.fetch(:on_start),
          on_stop: callbacks.fetch(:on_stop),
          on_refresh: callbacks.fetch(:on_refresh),
          on_switch_theme: callbacks.fetch(:on_switch_theme)
        )
      end
    end
  end
end
