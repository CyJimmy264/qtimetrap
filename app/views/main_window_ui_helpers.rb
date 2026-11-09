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
        apply_theme_styles(update_window_background: false, incremental: true)
        settings_store.write_theme_name(theme.name)
      end

      def apply_theme_styles(update_window_background: true, incremental: false)
        window.style_sheet = theme.stylesheet('application') if update_window_background
        sidebar_stylesheet = theme.stylesheet('project_sidebar')
        controls_stylesheet = theme.stylesheet('tracker_controls')
        entries_stylesheet = theme.stylesheet('entries_list')
        if incremental
          sidebar.widget.style_sheet = stylesheet_rule(sidebar_stylesheet, 'QWidget#sidebar_panel')
          entries.apply_theme_stylesheet(
            entries_stylesheet,
            external_targets: sidebar.theme_style_targets(sidebar_stylesheet) +
                              controls.theme_style_targets(controls_stylesheet),
            defer: true
          )
        else
          sidebar.widget.style_sheet = sidebar_stylesheet
          controls.widget.style_sheet = controls_stylesheet
          entries.apply_theme_stylesheet(entries_stylesheet)
        end
      end

      def stylesheet_rule(stylesheet, selector)
        stylesheet.scan(/([^{}]+)\{([^{}]*)\}/m).find do |selectors, _declarations|
          selectors.split(',').map(&:strip).include?(selector)
        end&.then do |selectors, declarations|
          "#{selectors.strip} {#{declarations}}"
        end.to_s
      end
    end
  end
end
