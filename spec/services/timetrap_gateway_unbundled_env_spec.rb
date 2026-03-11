# frozen_string_literal: true

require 'spec_helper'

RSpec.describe QTimetrap::Services::TimetrapGateway do
  subject(:gateway) { described_class.new(bin: 't') }

  let(:status) { instance_double(Process::Status, success?: true) }

  it 'runs cli commands in Bundler.with_unbundled_env' do
    stub_bundler_unbundled_env
    stub_const('Timetrap', Module.new)
    gateway.entries
    expect_unbundled_env_usage
  end

  private

  def stub_bundler_unbundled_env
    stub_bundler_module
    stub_bundler_unbundled_response
    stub_cli_entries_command
  end

  def expect_unbundled_env_usage
    expect(Bundler).to have_received(:with_unbundled_env)
    expect(Open3).to have_received(:capture2e).with('t', 'display', '--format', 'json')
  end

  def stub_bundler_module
    stub_const('Bundler', Module.new)
    allow(Bundler).to receive(:respond_to?).and_call_original
    allow(Bundler).to receive(:respond_to?).with(:with_unbundled_env).and_return(true)
  end

  def stub_bundler_unbundled_response
    allow(Bundler).to receive(:with_unbundled_env).and_yield
  end

  def stub_cli_entries_command
    allow(Open3).to receive(:capture2e).with('t', 'display', '--format', 'json').and_return(['[]', status])
  end
end
