# frozen_string_literal: true

QTimetrap::Application.configure do |config|
  config.theme_name = ENV.fetch('QTIMETRAP_THEME', config.theme_name)
end
