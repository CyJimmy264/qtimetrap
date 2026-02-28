# frozen_string_literal: true

QTimetrap::Application.configure do |config|
  config.enable_reloading = ENV['QTIMETRAP_RELOAD'] == '1'
end
