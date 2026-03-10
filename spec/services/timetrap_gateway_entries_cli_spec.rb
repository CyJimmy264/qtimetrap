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

  it 'parses JSON output from CLI' do
    json = <<~JSON
      [{"id":1,"note":"n1","sheet":"acme|core","start":"2026-02-28 10:00:00 +0000","end":"2026-02-28 11:00:00 +0000"}]
    JSON
    allow(Open3).to receive(:capture2e)
      .with('t', 'display', '--format', 'json')
      .and_return(cmd_result(output: json, success: true))
    entries = gateway.entries
    expect(entries.size).to eq(1)
    expect(entries.first.project).to eq('acme')
  end

  it 'returns empty array for invalid JSON' do
    allow(Open3).to receive(:capture2e)
      .with('t', 'display', '--format', 'json')
      .and_return(cmd_result(output: 'not-json', success: true))
    expect(gateway.entries).to eq([])
  end
end
