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
    allow(Open3).to receive(:capture2e).with('t', 'sheet', 'focus').and_return(cmd_result(output: '', success: true))
    allow(Open3).to receive(:capture2e).with('t', 'in').and_return(cmd_result(output: '', success: true))
    allow(Open3).to receive(:capture2e).with('t', 'out').and_return(cmd_result(output: '', success: true))
    gateway.start('focus')
    gateway.stop
    expect(Open3).to have_received(:capture2e).with('t', 'sheet', 'focus')
    expect(Open3).to have_received(:capture2e).with('t', 'in')
    expect(Open3).to have_received(:capture2e).with('t', 'out')
  end

  it 'normalizes sheet encoding for timetrap sheet command' do
    sheet = "focus-\xFF".b
    allow(Open3).to receive(:capture2e).and_return(cmd_result(output: '', success: true))

    gateway.start(sheet)

    expect(Open3).to have_received(:capture2e).with(
      't', 'sheet', satisfy { |value| value.encoding == Encoding::UTF_8 && value == 'focus-' }
    )
  end
end
