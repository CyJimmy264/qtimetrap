# frozen_string_literal: true

module QTimetrap
  module Views
    # Loads the app icon with SVG primary source and PNG fallback.
    class WindowIconLoader
      def initialize(window:, root:)
        @window = window
        @root = root
      end

      def apply
        candidates = icon_candidates
        return if candidates.empty?

        icon = QIcon.new(candidates.first)
        add_fallbacks(icon, candidates.drop(1))
        window.window_icon = icon
      end

      private

      attr_reader :window, :root

      def icon_candidates
        icons_dir = File.join(root, 'app', 'assets', 'icons')
        svg_path = File.join(icons_dir, 'qtimetrap-icon.svg')
        png_fallback = File.join(icons_dir, 'qtimetrap-icon-256.png')
        [svg_path, png_fallback].select { |path| File.exist?(path) }
      end

      def add_fallbacks(icon, paths)
        paths.each { |path| icon.add_file(path) }
      end
    end
  end
end
