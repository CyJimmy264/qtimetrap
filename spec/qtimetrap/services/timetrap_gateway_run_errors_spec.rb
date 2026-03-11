# frozen_string_literal: true

require 'spec_helper'

RSpec.describe QTimetrap::Services::TimetrapGateway do
  subject(:gateway) { described_class.new(bin: 't', logger: logger) }

  let(:logger) { instance_double(QTimetrap::Services::TimetrapGatewayLogger, log_cli: nil, log_api: nil) }

  it 'returns formatted failure when executable is missing' do
    allow(Open3).to receive(:capture2e).and_raise(Errno::ENOENT)
    run_result = gateway.send(:run, 'display')
    expect_run_failure(run_result, include('Command not found: t'))
    expect_cli_failure_log(include('Command not found: t'))
  end

  it 'returns formatted failure for generic runtime exceptions' do
    allow(Open3).to receive(:capture2e).and_raise(StandardError, 'boom')
    run_result = gateway.send(:run, 'display')
    expect_run_failure(run_result, 'StandardError: boom')
    expect_cli_failure_log('StandardError: boom')
  end

  private

  def expect_run_failure(run_result, message)
    expect(run_result.first).to be(false)
    expect(run_result.last).to match(message)
  end

  def expect_cli_failure_log(output)
    expect(logger).to have_received(:log_cli).with(
      bin: 't',
      args: ['display'],
      success: false,
      output: output
    )
  end
end
