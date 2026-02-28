# frozen_string_literal: true

require 'date'
require 'simplecov'

SimpleCov.start do
  add_filter '/spec/'
end

$LOAD_PATH.unshift(File.expand_path('../lib', __dir__))
require 'qtimetrap'
QTimetrap::Application.loader.setup
Dir[File.expand_path('support/**/*.rb', __dir__)].sort.each { |file| require file }

RSpec.configure do |config|
  config.order = :random
  Kernel.srand config.seed
end
