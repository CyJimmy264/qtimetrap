# frozen_string_literal: true

require 'date'
require 'simplecov'
require 'stringio'

SimpleCov.start do
  add_filter '/spec/'
end

$LOAD_PATH.unshift(File.expand_path('../lib', __dir__))
require 'qtimetrap'
QTimetrap::Application.loader.setup
Dir[File.expand_path('support/**/*.rb', __dir__)].each { |file| require file }

RSpec.configure do |config|
  config.order = :random
  Kernel.srand config.seed

  config.around(:example, :silence_stderr) do |example|
    original_stderr = $stderr
    $stderr = StringIO.new
    example.run
  ensure
    $stderr = original_stderr
  end
end
