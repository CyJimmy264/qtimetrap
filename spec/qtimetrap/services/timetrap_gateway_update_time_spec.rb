# frozen_string_literal: true

require 'spec_helper'

RSpec.describe QTimetrap::Services::TimetrapGateway do
  subject(:gateway) { described_class.new }

  let(:start_time) { Time.new(2026, 3, 1, 10, 15, 0, '+00:00') }
  let(:end_time) { Time.new(2026, 3, 1, 11, 30, 0, '+00:00') }

  it 'updates start and end via API when timetrap API is available' do
    entry = stub_time_api_entry

    gateway.update_time(42, start_time: start_time, end_time: end_time)

    expect_time_update(entry)
  end

  it 'updates start and end via CLI when API is unavailable' do
    stub_const('Timetrap', Module.new)
    stub_cli_time_update
    gateway.update_time(42, start_time: start_time, end_time: end_time)
    expect_cli_time_update
  end

  def expected_cli_args
    [
      't',
      'edit',
      '--id',
      '42',
      '--start',
      '2026-03-01 10:15:00 +0000',
      '--end',
      '2026-03-01 11:30:00 +0000'
    ]
  end

  def stub_time_api_entry
    stub_time_api_constants
    entry = instance_double(time_entry_class)
    stub_entry_lookup(entry)
    stub_entry_persistence(entry)
    entry
  end

  def stub_time_api_constants
    stub_const('Timetrap', Module.new)
    Timetrap.const_set(:Entry, time_entry_class)
    Timetrap.const_set(:Timer, Class.new)
  end

  def time_entry_class
    @time_entry_class ||= Class.new do
      attr_accessor :start, :end

      def save; end
    end
  end

  def stub_entry_lookup(entry)
    allow(Timetrap::Entry).to receive(:[]).with(42).and_return(entry)
  end

  def stub_entry_persistence(entry)
    allow(entry).to receive(:start=)
    allow(entry).to receive(:end=)
    allow(entry).to receive(:save)
  end

  def expect_time_update(entry)
    expect(entry).to have_received(:start=).with(start_time)
    expect(entry).to have_received(:end=).with(end_time)
    expect(entry).to have_received(:save)
  end

  def stub_cli_time_update
    allow(Open3).to receive(:capture2e)
      .with(*expected_cli_args)
      .and_return(cmd_result(output: '', success: true))
  end

  def expect_cli_time_update
    expect(Open3).to have_received(:capture2e).with(*expected_cli_args)
  end
end
