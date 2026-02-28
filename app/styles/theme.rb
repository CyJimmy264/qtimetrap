# frozen_string_literal: true

module QTimetrap
  module Styles
    # Loads and composes QSS theme assets for the application.
    class Theme
      FILES = %w[application project_sidebar tracker_controls entries_list].freeze
      DEFAULT = 'light'
      SUPPORTED = %w[light dark].freeze

      def initialize(name:, root:)
        @name = normalize_name(name)
        @root = root
        @cache = {}
      end

      attr_reader :name, :root

      def application_stylesheet
        FILES.map { |file| stylesheet(file) }.join("\n")
      end

      def with_name(next_name)
        self.class.new(name: next_name, root: root)
      end

      def snippet(name)
        File.read(path_for_snippet(name))
      end

      def stylesheet(file_name)
        cache.fetch(file_name) do
          cache[file_name] = File.read(path_for(file_name))
        end
      end

      private

      attr_reader :cache

      def path_for(file_name)
        path = File.join(root, 'app', 'styles', 'themes', name, "#{file_name}.qss")
        return path if File.exist?(path)

        File.join(root, 'app', 'styles', 'themes', DEFAULT, "#{file_name}.qss")
      end

      def path_for_snippet(name)
        path = File.join(root, 'app', 'styles', 'themes', name, 'snippets', "#{name}.qss")
        return path if File.exist?(path)

        File.join(root, 'app', 'styles', 'themes', DEFAULT, 'snippets', "#{name}.qss")
      end

      def normalize_name(value)
        candidate = value.to_s.strip.downcase
        SUPPORTED.include?(candidate) ? candidate : DEFAULT
      end
    end
  end
end
