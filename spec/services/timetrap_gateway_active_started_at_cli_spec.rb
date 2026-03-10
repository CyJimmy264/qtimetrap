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

  it 'parses started_at from timetrap now output' do
    out = '2026-02-28 09:30:00 +0000 some text'
    allow(Open3).to receive(:capture2e).with('t', 'now').and_return(cmd_result(output: out, success: true))
    result = gateway.active_started_at
    expect(result).to be_a(Time)
    expect(result.strftime('%Y-%m-%d %H:%M:%S %z')).to eq('2026-02-28 09:30:00 +0000')
  end

  it 'returns nil on command failure' do
    allow(Open3).to receive(:capture2e).with('t', 'now').and_return(cmd_result(output: 'err', success: false))
    expect(gateway.active_started_at).to be_nil
  end
end
