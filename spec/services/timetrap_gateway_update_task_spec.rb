# frozen_string_literal: true

require 'spec_helper'

RSpec.describe QTimetrap::Services::TimetrapGateway do
  subject(:gateway) { described_class.new }

  let(:sheet) { 'acme|deploy' }

  it 'updates task via API when timetrap API is available' do
    stub_timetrap_api!
    entry = stub_api_task_update_entry
    gateway.update_task(42, sheet)
    expect_api_task_update(entry)
  end

  it 'updates task via CLI when API is unavailable' do
    stub_const('Timetrap', Module.new)
    stub_cli_task_update
    gateway.update_task(42, sheet)
    expect_cli_task_update
  end

  private

  def stub_api_task_update_entry
    entry_class = Class.new do
      def id; end

      def update(**); end
    end
    instance_double(entry_class).tap do |entry|
      allow(Timetrap::Entry).to receive(:[]).with(42).and_return(entry)
      allow(Timetrap::Timer).to receive(:active_entry).and_return(entry)
      allow(Timetrap::Timer).to receive(:current_sheet=)
      allow(entry).to receive(:id).and_return(42)
      allow(entry).to receive(:update)
    end
  end

  def expect_api_task_update(entry)
    expect(Timetrap::Timer).to have_received(:current_sheet=).with(sheet)
    expect(entry).to have_received(:update).with(sheet: sheet)
  end

  def stub_cli_task_update
    allow(Open3).to receive(:capture2e)
      .with('t', 'edit', '--id', '42', '--move', sheet)
      .and_return(cmd_result(output: '', success: true))
  end

  def expect_cli_task_update
    expect(Open3).to have_received(:capture2e).with('t', 'edit', '--id', '42', '--move', sheet)
  end
end
