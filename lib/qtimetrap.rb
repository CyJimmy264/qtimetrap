# frozen_string_literal: true

require 'qt'
require 'zeitwerk'

require_relative 'qtimetrap/version'
require_relative 'qtimetrap/configuration'
require_relative 'qtimetrap/container'
require_relative '../config/application'

module QTimetrap
  # CLI entrypoint for launching the Qt desktop application.
  class CLI
    def self.start(_argv = [])
      app = QTimetrap::Application.boot!
      main_window = QTimetrap::Application.container.fetch(:main_window)
      previous_int = Signal.trap('INT') { main_window.request_shutdown }
      main_window.show
      app.exec
    ensure
      Signal.trap('INT', previous_int) if defined?(previous_int) && previous_int
      app&.dispose
    end
  end
end
