# frozen_string_literal: true

module QTimetrap
  module Views
    # Builds main window layout and returns initialized component instances.
    class MainWindowLayoutBuilder
      include MainWindowSplitterToggleHelpers

      SIDEBAR_WIDTH = 220
      SIDEBAR_MIN_WIDTH = 180
      SIDEBAR_MAX_WIDTH = 520

      def initialize(window:, callbacks:)
        @window = window
        @callbacks = callbacks
      end

      def build
        root = QHBoxLayout.new(window)
        root.set_contents_margins(0, 0, 0, 0)
        root.set_spacing(0)
        splitter, sidebar, controls, entries = build_splitter_and_content
        root.add_widget(splitter)
        { sidebar: sidebar, controls: controls, entries: entries }
      end

      private

      attr_reader :window, :callbacks

      def build_splitter_and_content
        splitter = QSplitter.new(window)
        splitter.set_orientation(Qt::Horizontal)
        splitter.set_mouse_tracking(true)
        sidebar = build_sidebar(parent: splitter)
        content, controls, entries = build_content(parent: splitter)
        splitter.add_widget(sidebar.widget)
        splitter.add_widget(content)
        configure_splitter(splitter)
        add_sidebar_toggle_button(window: window, splitter: splitter, sidebar_widget: sidebar.widget)
        [splitter, sidebar, controls, entries]
      end

      def configure_splitter(splitter)
        splitter.set_stretch_factor(0, 0)
        splitter.set_stretch_factor(1, 1)
        splitter.set_collapsible(0, false)
        splitter.set_collapsible(1, false)
      end

      def build_sidebar(parent:)
        Components::ProjectSidebarComponent.new(
          parent: parent,
          on_project_selected: callbacks.fetch(:on_project_selected),
          on_task_selected: callbacks.fetch(:on_task_selected)
        ).tap do |component|
          component.widget.set_base_size(SIDEBAR_WIDTH, 0)
          component.widget.set_minimum_width(SIDEBAR_MIN_WIDTH)
          component.widget.set_maximum_width(SIDEBAR_MAX_WIDTH)
        end
      end

      def build_content(parent:)
        content, layout = build_content_widget(parent: parent)
        controls = build_controls(content)
        entries = Components::EntriesListComponent.new(parent: content)
        layout.add_widget(controls.widget)
        layout.add_widget(entries.widget)
        layout.set_stretch(1, 1)
        [content, controls, entries]
      end

      def build_content_widget(parent:)
        content = QWidget.new(parent)
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
