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

  it 'parses active_started_at from binary CLI output' do
    output = (+"Active since 2026-02-28 10:11:12 +0000\n").force_encoding(Encoding::ASCII_8BIT)
    allow(Open3).to receive(:capture2e).with('t', 'now').and_return(cmd_result(output: output, success: true))

    result = gateway.active_started_at

    expect(result).to eq(Time.parse('2026-02-28 10:11:12 +0000'))
  end

  it 'parses entries from binary JSON CLI output' do
    stub_binary_json_entries
    entries = gateway.entries
    expect_binary_entries(entries)
  end

  private

  def stub_binary_json_entries
    json = <<~JSON
      [{"id":1,"note":"n1","sheet":"acme|core","start":"2026-02-28 10:00:00 +0000","end":"2026-02-28 11:00:00 +0000"}]
    JSON
    output = (+json).force_encoding(Encoding::ASCII_8BIT)
    allow(Open3).to receive(:capture2e)
      .with('t', 'display', '--format', 'json')
      .and_return(cmd_result(output: output, success: true))
  end

  def expect_binary_entries(entries)
    entry = expect_single_binary_entry(entries)
    expect_binary_entry_fields(entry)
  end

  def expect_single_binary_entry(entries)
    expect(entries.size).to eq(1)
    entries.first
  end

  def expect_binary_entry_fields(entry)
    expect(entry.sheet).to eq('acme|core')
    expect(entry.project).to eq('acme')
    expect(entry.task).to eq('core')
  end
end
