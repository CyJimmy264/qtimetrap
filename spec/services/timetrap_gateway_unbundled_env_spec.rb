# frozen_string_literal: true

require 'spec_helper'

RSpec.describe QTimetrap::Services::TimetrapGateway do
  subject(:gateway) { described_class.new(bin: 't') }

  let(:status) { instance_double(Process::Status, success?: true) }

  it 'runs cli commands in Bundler.with_unbundled_env' do
    bundler = class_double(Bundler).as_stubbed_const
    allow(bundler).to receive(:respond_to?).with(:with_unbundled_env).and_return(true)
    allow(bundler).to receive(:with_unbundled_env).and_yield
    allow(Open3).to receive(:capture2e).with('t', 'display', '--format', 'json').and_return(['[]', status])

    gateway.entries

    expect(bundler).to have_received(:with_unbundled_env)
    expect(Open3).to have_received(:capture2e).with('t', 'display', '--format', 'json')
  end
end
