# frozen_string_literal: true

require 'spec_helper'

RSpec.describe QTimetrap::Services::TimetrapGateway do
  subject(:gateway) { gateway_class.new }

  let(:gateway_class) do
    Class.new(described_class) do
      private

      def api_available?
        false
      end
    end
  end

  it 'calls timetrap in/out commands' do
    stub_start_stop_commands
    run_start_stop_commands
    expect_start_stop_commands
  end

  it 'normalizes sheet encoding for timetrap sheet command' do
    gateway.start(binary_sheet_name)
    expect_normalized_sheet_command
  end

  private

  def stub_start_stop_commands
    stub_cli_success('t', 'sheet', 'focus')
    stub_cli_success('t', 'in')
    stub_cli_success('t', 'out')
  end

  def run_start_stop_commands
    gateway.start('focus')
    gateway.stop
  end

  def expect_start_stop_commands
    expect(Open3).to have_received(:capture2e).with('t', 'sheet', 'focus')
    expect(Open3).to have_received(:capture2e).with('t', 'in')
    expect(Open3).to have_received(:capture2e).with('t', 'out')
  end

  def binary_sheet_name
    allow(Open3).to receive(:capture2e).and_return(cmd_result(output: '', success: true))
    "focus-\xFF".b
  end

  def stub_cli_success(*args)
    allow(Open3).to receive(:capture2e).with(*args).and_return(cmd_result(output: '', success: true))
  end

  def expect_normalized_sheet_command
    expect(Open3).to have_received(:capture2e).with(
      't', 'sheet', satisfy { |value| value.encoding == Encoding::UTF_8 && value == 'focus-' }
    )
  end
end
