# frozen_string_literal: true

require 'fileutils'
require 'yaml'

module QTimetrap
  module Services
    # Persists lightweight UI settings in a YAML file under user config.
    class SettingsStore
      def initialize(path: default_path)
        @path = path
      end

      def read_theme_name
        data['theme']
      end

      def write_theme_name(theme_name)
        value = theme_name.to_s.strip
        return if value.empty?

        payload = data.merge('theme' => value)
        FileUtils.mkdir_p(File.dirname(path))
        File.write(path, payload.to_yaml)
      end

      def read_window_geometry
        value = data['window']
        return nil unless value.is_a?(Hash)

        geometry = stringify_keys(value)
        parse_window_geometry(geometry)
      end

      def write_window_geometry(left:, top:, width:, height:)
        payload = data.merge(
          'window' => {
            'left' => Integer(left),
            'top' => Integer(top),
            'width' => Integer(width),
            'height' => Integer(height)
          }
        )
        FileUtils.mkdir_p(File.dirname(path))
        File.write(path, payload.to_yaml)
      end

      private

      attr_reader :path

      def data
        return {} unless File.exist?(path)

        loaded = YAML.safe_load_file(path, permitted_classes: [], aliases: false)
        loaded.is_a?(Hash) ? stringify_keys(loaded) : {}
      rescue Psych::SyntaxError
        {}
      end

      def stringify_keys(hash)
        hash.each_with_object({}) { |(k, v), memo| memo[k.to_s] = v }
      end

      def parse_window_geometry(geometry)
        left = Integer(geometry['left'] || geometry['x'])
        top = Integer(geometry['top'] || geometry['y'])
        width = Integer(geometry['width'])
        height = Integer(geometry['height'])
        return nil unless width.positive? && height.positive?

        { left: left, top: top, width: width, height: height }
      rescue ArgumentError, TypeError
        nil
      end

      def default_path
        config_home = ENV.fetch('XDG_CONFIG_HOME', File.join(Dir.home, '.config'))
        File.join(config_home, 'qtimetrap', 'config.yml')
      end
    end
  end
end
