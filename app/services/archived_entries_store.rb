# frozen_string_literal: true

require 'fileutils'
require 'set'
require 'yaml'

module QTimetrap
  module Services
    # Persists archived Timetrap entry ids in a local app-owned store.
    class ArchivedEntriesStore
      def initialize(path: default_path)
        @path = path
      end

      def archived_ids
        read_ids.to_a.sort
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

      def unarchive(entry_id)
        id = Integer(entry_id)
        ids = read_ids
        return unless ids.delete(id)

        write_ids(ids)
      rescue ArgumentError, TypeError
        nil
      end

      private

      attr_reader :path

      def read_ids
        return @ids_cache if @ids_cache
        return @ids_cache = Set.new unless File.exist?(path)

        payload = YAML.safe_load_file(path, permitted_classes: [], aliases: false)
        return @ids_cache = Set.new unless payload.is_a?(Hash)

        values = Array(payload['archived_entry_ids']).filter_map { |value| Integer(value) }.uniq
        @ids_cache = Set.new(values)
      rescue Psych::SyntaxError, ArgumentError, TypeError
        @ids_cache = Set.new
      end

      def write_ids(ids)
        FileUtils.mkdir_p(File.dirname(path))
        normalized_ids = ids.uniq.sort
        File.write(path, { 'archived_entry_ids' => normalized_ids }.to_yaml)
        @ids_cache = Set.new(normalized_ids)
      end

      def default_path
        data_home = ENV.fetch('XDG_DATA_HOME', File.join(Dir.home, '.local', 'share'))
        File.join(data_home, 'qtimetrap', 'archived_entries.yml')
      end
    end
  end
end
