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
          widget.window_title = 'QTimetrap'
          widget.object_name = 'main_window'
          widget.set_geometry(40, 40, self.class::WINDOW_W, self.class::WINDOW_H)
        end
      end

      def apply_theme
        Application.configuration.theme_name = theme.name
        window.style_sheet = theme.application_stylesheet
        settings_store.write_theme_name(theme.name)
      end
    end
  end
end
