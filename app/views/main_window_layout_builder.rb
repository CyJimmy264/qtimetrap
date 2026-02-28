# frozen_string_literal: true

module QTimetrap
  module Views
    # Builds main window layout and returns initialized component instances.
    class MainWindowLayoutBuilder
      SIDEBAR_WIDTH = 220

      def initialize(window:, on_project_selected:, on_start:, on_stop:, on_refresh:, on_switch_theme:)
        @window = window
        @on_project_selected = on_project_selected
        @on_start = on_start
        @on_stop = on_stop
        @on_refresh = on_refresh
        @on_switch_theme = on_switch_theme
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

      attr_reader :window, :on_project_selected, :on_start, :on_stop, :on_refresh, :on_switch_theme

      def build_sidebar
        Components::ProjectSidebarComponent.new(
          parent: window,
          on_project_selected: on_project_selected
        ).tap { |component| component.widget.set_fixed_width(SIDEBAR_WIDTH) }
      end

      def build_content
        content = QWidget.new(window)
        layout = QVBoxLayout.new(content)
        layout.set_contents_margins(14, 8, 14, 8)
        layout.set_spacing(10)
        controls = Components::TrackerControlsComponent.new(
          parent: content,
          on_start: on_start,
          on_stop: on_stop,
          on_refresh: on_refresh,
          on_switch_theme: on_switch_theme
        )
        entries = Components::EntriesListComponent.new(parent: content)
        layout.add_widget(controls.widget)
        layout.add_widget(entries.widget)
        layout.set_stretch(1, 1)
        [content, controls, entries]
      end
    end
  end
end
