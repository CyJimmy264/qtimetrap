# frozen_string_literal: true

require 'fileutils'
require 'yaml'

module QTimetrap
  module Services
    # Persists archived Timetrap entry ids in a local app-owned store.
    class ArchivedEntriesStore
      def initialize(path: default_path)
        @path = path
      end

      def archived_ids
        read_ids
      end

      def archived?(entry_id)
        read_ids.include?(Integer(entry_id))
      rescue ArgumentError, TypeError
        false
      end

      def archive(entry_id)
        id = Integer(entry_id)
        ids = read_ids
        return if ids.include?(id)

        ids << id
        write_ids(ids)
      rescue ArgumentError, TypeError
        nil
      end

      private

      attr_reader :path

      def read_ids
        return [] unless File.exist?(path)

        payload = YAML.safe_load_file(path, permitted_classes: [], aliases: false)
        return [] unless payload.is_a?(Hash)

        Array(payload['archived_entry_ids']).filter_map { |value| Integer(value) }.uniq.sort
      rescue Psych::SyntaxError, ArgumentError, TypeError
        []
      end

      def write_ids(ids)
        FileUtils.mkdir_p(File.dirname(path))
        File.write(path, { 'archived_entry_ids' => ids.uniq.sort }.to_yaml)
      end

      def default_path
        data_home = ENV.fetch('XDG_DATA_HOME', File.join(Dir.home, '.local', 'share'))
        File.join(data_home, 'qtimetrap', 'archived_entries.yml')
      end
    end
  end
end
