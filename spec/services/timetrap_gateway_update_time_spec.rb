# frozen_string_literal: true

require 'spec_helper'

RSpec.describe QTimetrap::Services::TimetrapGateway do
  subject(:gateway) { described_class.new }

  let(:start_time) { Time.new(2026, 3, 1, 10, 15, 0, '+00:00') }
  let(:end_time) { Time.new(2026, 3, 1, 11, 30, 0, '+00:00') }

  it 'updates start and end via API when timetrap API is available' do
    entry_klass = Class.new do
      attr_accessor :start, :end

      def save; end
    end
    stub_const('Timetrap', Module.new)
    Timetrap.const_set(:Entry, entry_klass)
    Timetrap.const_set(:Timer, Class.new)
    entry = instance_double(entry_klass)
    allow(Timetrap::Entry).to receive(:[]).with(42).and_return(entry)
    allow(entry).to receive(:start=)
    allow(entry).to receive(:end=)
    allow(entry).to receive(:save)

    gateway.update_time(42, start_time: start_time, end_time: end_time)

    expect(entry).to have_received(:start=).with(start_time)
    expect(entry).to have_received(:end=).with(end_time)
    expect(entry).to have_received(:save)
  end

  it 'updates start and end via CLI when API is unavailable' do
    stub_const('Timetrap', Module.new)
    allow(Open3).to receive(:capture2e)
      .with(*expected_cli_args)
      .and_return(cmd_result(output: '', success: true))

    gateway.update_time(42, start_time: start_time, end_time: end_time)

    expect(Open3).to have_received(:capture2e).with(*expected_cli_args)
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
end
