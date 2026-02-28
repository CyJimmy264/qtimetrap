# frozen_string_literal: true

module QTimetrap
  module Views
    # UI helper methods extracted from MainWindow runtime logic.
    module MainWindowUiHelpers
      private

      def next_theme_name
        themes = self.class::THEMES
        current = themes.index(theme.name) || 0
        themes[(current + 1) % themes.length]
      end

      def set_window_icon
        WindowIconLoader.new(window: window, root: Application.root).apply
      rescue StandardError => e
        warn("[qtimetrap] icon load failed: #{e.class}: #{e.message}")
      end

      def extract_event_value(event, key)
        return unless event.respond_to?(:[])

        value = event[key]
        return value.to_i if value

        nil
      end

      def build_base_window
        QWidget.new do |widget|
          widget.set_window_title('QTimetrap')
          assign_name(widget, 'main_window')
          widget.set_geometry(40, 40, self.class::WINDOW_W, self.class::WINDOW_H)
        end
      end

      def apply_theme
        Application.configuration.theme_name = theme.name
        window.set_style_sheet(theme.application_stylesheet)
        settings_store.write_theme_name(theme.name)
      end

      def assign_name(widget, value)
        if widget.respond_to?(:set_object_name)
          widget.set_object_name(value)
        elsif widget.respond_to?(:setObjectName)
          widget.setObjectName(value)
        end
      end
    end
  end
end
