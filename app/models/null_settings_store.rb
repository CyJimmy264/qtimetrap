# frozen_string_literal: true

module QTimetrap
  module Models
    # No-op settings persistence implementation used as a safe fallback.
    class NullSettingsStore
      def write_theme_name(_theme_name); end
      def read_window_geometry; end
      def write_window_geometry(left:, top:, width:, height:); end
    end
  end
end
