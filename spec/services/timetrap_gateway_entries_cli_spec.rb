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
    stub_cli_entries_output(valid_json_entries)
    entries = gateway.entries
    expect_cli_entries(entries)
  end

  it 'returns empty array for invalid JSON' do
    stub_cli_entries_output('not-json')
    expect(gateway.entries).to eq([])
  end

  private

  def valid_json_entries
    <<~JSON
      [{"id":1,"note":"n1","sheet":"acme|core","start":"2026-02-28 10:00:00 +0000","end":"2026-02-28 11:00:00 +0000"}]
    JSON
  end

  def stub_cli_entries_output(output)
    allow(Open3).to receive(:capture2e)
      .with('t', 'display', '--format', 'json')
      .and_return(cmd_result(output: output, success: true))
  end

  def expect_cli_entries(entries)
    expect(entries.size).to eq(1)
    expect(entries.first.project).to eq('acme')
  end
end
