# frozen_string_literal: true

require 'spec_helper'

RSpec.describe QTimetrap::Services::TimetrapGateway do
  subject(:gateway) { described_class.new(bin: 't') }

  it 'returns formatted failure when executable is missing' do
    allow(Open3).to receive(:capture2e).and_raise(Errno::ENOENT)

    ok, message = gateway.send(:run, 'display')
    expect(ok).to be(false)
    expect(message).to include('Command not found: t')
  end

  it 'returns formatted failure for generic runtime exceptions' do
    allow(Open3).to receive(:capture2e).and_raise(StandardError, 'boom')

    ok, message = gateway.send(:run, 'display')
    expect(ok).to be(false)
    expect(message).to eq('StandardError: boom')
  end
end
