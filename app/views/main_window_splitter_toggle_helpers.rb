# frozen_string_literal: true

module QTimetrap
  module Views
    # Sidebar collapse/expand toggle attached to splitter handle area.
    module MainWindowSplitterToggleHelpers
      include MainWindowSplitterToggleLayoutHelpers
      include MainWindowSplitterToggleBootstrapHelpers
      include MainWindowSplitterToggleHoverHelpers

      SIDEBAR_TOGGLE_W = 20
      SIDEBAR_TOGGLE_H = 56
      SIDEBAR_TOGGLE_ZONE_W = 24
      SIDEBAR_TOGGLE_ZONE_H = 128

      private

      def add_sidebar_toggle_button(window:, splitter:, sidebar_widget:)
        button = build_sidebar_toggle_button(window)
        zone = build_sidebar_toggle_zone(window)
        state = { collapsed: false, button_hovered: false, zone_hovered: false }
        button.connect('clicked') { |_| on_sidebar_toggle_clicked(splitter, sidebar_widget, button, zone, state) }
        bind_splitter_toggle_events(
          splitter: splitter,
          sidebar_widget: sidebar_widget,
          button: button,
          zone: zone,
          state: state
        )
        bind_toggle_button_events(button: button, state: state)
        reposition_toggle_affordance(splitter: splitter, sidebar_widget: sidebar_widget, button: button, zone: zone)
        schedule_initial_toggle_reposition(
          splitter: splitter,
          sidebar_widget: sidebar_widget,
          button: button,
          zone: zone
        )
      end

      def build_sidebar_toggle_button(window)
        QPushButton.new(window).tap do |button|
          button.set_object_name('sidebar_toggle_button')
          button.set_text('◀')
          button.set_focus_policy(Qt::NoFocus)
          button.set_tool_tip('Collapse sidebar')
          button.set_fixed_size(SIDEBAR_TOGGLE_W, SIDEBAR_TOGGLE_H)
          button.raise
          button.hide
        end
      end

      def on_sidebar_toggle_clicked(splitter, sidebar_widget, button, zone, state)
        state[:collapsed] = !state[:collapsed]
        update_sidebar_visibility(sidebar_widget, button, collapsed: state[:collapsed])
        reposition_toggle_affordance(splitter: splitter, sidebar_widget: sidebar_widget, button: button, zone: zone)
      end

      def build_sidebar_toggle_zone(window)
        QWidget.new(window).tap do |zone|
          zone.set_object_name('sidebar_toggle_hotspot')
          zone.set_fixed_size(SIDEBAR_TOGGLE_ZONE_W, SIDEBAR_TOGGLE_ZONE_H)
          zone.set_style_sheet('background: transparent;')
          zone.raise
        end
      end

      def bind_splitter_toggle_events(splitter:, sidebar_widget:, button:, zone:, state:)
        splitter.connect('splitterMoved') do |_|
          reposition_toggle_affordance(splitter: splitter, sidebar_widget: sidebar_widget, button: button, zone: zone)
        end
        splitter.on(:resize) do |_|
          reposition_toggle_affordance(splitter: splitter, sidebar_widget: sidebar_widget, button: button, zone: zone)
        end
        sidebar_widget.on(:resize) do |_|
          reposition_toggle_affordance(splitter: splitter, sidebar_widget: sidebar_widget, button: button, zone: zone)
        end
        bind_toggle_zone_events(zone: zone, button: button, state: state)
      end

      def reposition_toggle_affordance(splitter:, sidebar_widget:, button:, zone:)
        x = toggle_x(splitter: splitter, sidebar_widget: sidebar_widget)
        y = toggle_y(splitter_height: splitter.height)
        button.move(x, y)
        button.raise
        zone_x = x - ((SIDEBAR_TOGGLE_ZONE_W - SIDEBAR_TOGGLE_W) / 2)
        zone_y = y - ((SIDEBAR_TOGGLE_ZONE_H - SIDEBAR_TOGGLE_H) / 2)
        zone.move(zone_x, zone_y)
      end

      def update_sidebar_visibility(sidebar_widget, button, collapsed:)
        if collapsed
          sidebar_widget.hide
          button.set_text('▶')
          button.set_tool_tip('Expand sidebar')
        else
          sidebar_widget.show
          button.set_text('◀')
          button.set_tool_tip('Collapse sidebar')
        end
      end
    end
  end
end
