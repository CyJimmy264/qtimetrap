# frozen_string_literal: true

module CommandHelpers
  def cmd_result(output:, success:)
    [output, instance_double(Process::Status, success?: success)]
  end
end

RSpec.configure do |config|
  config.include CommandHelpers
end
