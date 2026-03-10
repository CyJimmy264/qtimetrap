# frozen_string_literal: true

require 'spec_helper'

RSpec.describe QTimetrap::Services::TimetrapGateway do
  subject(:gateway) { described_class.new }

  before do
    allow(gateway).to receive(:api_available?).and_return(false)
  end

  it 'parses active_started_at from binary CLI output' do
    output = (+"Active since 2026-02-28 10:11:12 +0000\n").force_encoding(Encoding::ASCII_8BIT)
    allow(Open3).to receive(:capture2e).with('t', 'now').and_return(cmd_result(output: output, success: true))

    result = gateway.active_started_at

    expect(result).to eq(Time.parse('2026-02-28 10:11:12 +0000'))
  end

  it 'parses entries from binary JSON CLI output' do
    json = <<~JSON
      [{"id":1,"note":"n1","sheet":"acme|core","start":"2026-02-28 10:00:00 +0000","end":"2026-02-28 11:00:00 +0000"}]
    JSON
    output = (+json).force_encoding(Encoding::ASCII_8BIT)
    allow(Open3).to receive(:capture2e)
      .with('t', 'display', '--format', 'json')
      .and_return(cmd_result(output: output, success: true))

    entries = gateway.entries

    expect(entries.size).to eq(1)
    expect(entries.first.sheet).to eq('acme|core')
    expect(entries.first.project).to eq('acme')
    expect(entries.first.task).to eq('core')
  end
end
