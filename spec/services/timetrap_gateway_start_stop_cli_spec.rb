# frozen_string_literal: true

require 'spec_helper'

RSpec.describe QTimetrap::Services::TimetrapGateway do
  subject(:gateway) { described_class.new }

  before do
    allow(gateway).to receive(:api_available?).and_return(false)
  end

  it 'calls timetrap in/out commands' do
    allow(Open3).to receive(:capture2e).with('t', 'in', 'focus').and_return(cmd_result(output: '', success: true))
    allow(Open3).to receive(:capture2e).with('t', 'out').and_return(cmd_result(output: '', success: true))
    gateway.start('focus')
    gateway.stop
    expect(Open3).to have_received(:capture2e).with('t', 'in', 'focus')
    expect(Open3).to have_received(:capture2e).with('t', 'out')
  end
end
