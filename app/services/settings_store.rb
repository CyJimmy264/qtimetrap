# frozen_string_literal: true

require 'fileutils'
require 'yaml'

module QTimetrap
  module Services
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

      private

      attr_reader :path

      def data
        return {} unless File.exist?(path)

        loaded = YAML.safe_load(File.read(path), permitted_classes: [], aliases: false)
        loaded.is_a?(Hash) ? stringify_keys(loaded) : {}
      rescue Psych::SyntaxError
        {}
      end

      def stringify_keys(hash)
        hash.each_with_object({}) { |(k, v), memo| memo[k.to_s] = v }
      end

      def default_path
        config_home = ENV.fetch('XDG_CONFIG_HOME', File.join(Dir.home, '.config'))
        File.join(config_home, 'qtimetrap', 'config.yml')
      end
    end
  end
end
