# frozen_string_literal: true

QTimetrap::Application.configure do |config|
  config.timetrap_bin = ENV.fetch('TIMETRAP_BIN', config.timetrap_bin)
end
