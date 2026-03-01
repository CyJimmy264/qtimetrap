# frozen_string_literal: true

require 'spec_helper'

RSpec.describe QTimetrap::Services::TimetrapGateway do
  subject(:gateway) { described_class.new }

  it 'updates note via API when timetrap API is available' do
    entry_klass = Class.new do
      attr_accessor :note

      def save; end
    end
    stub_const('Timetrap', Module.new)
    Timetrap.const_set(:Entry, entry_klass)
    Timetrap.const_set(:Timer, Class.new)
    entry = instance_double(entry_klass)
    allow(Timetrap::Entry).to receive(:[]).with(42).and_return(entry)
    allow(entry).to receive(:note=)
    allow(entry).to receive(:save)

    gateway.update_note(42, 'updated note')

    expect(Timetrap::Entry).to have_received(:[]).with(42)
    expect(entry).to have_received(:note=).with('updated note')
    expect(entry).to have_received(:save)
  end

  it 'raises when API entry is not found by id' do
    entry_klass = Class.new do
      attr_accessor :note

      def save; end
    end
    stub_const('Timetrap', Module.new)
    Timetrap.const_set(:Entry, entry_klass)
    Timetrap.const_set(:Timer, Class.new)
    allow(Timetrap::Entry).to receive(:[]).with(42).and_return(nil)

    expect { gateway.update_note(42, 'updated note') }
      .to raise_error(TypeError, /Unsupported entry lookup result: NilClass/)
  end

  it 'updates note via CLI when API is unavailable' do
    allow(Open3).to receive(:capture2e)
      .with('t', 'edit', '--id', '42', 'updated note')
      .and_return(cmd_result(output: '', success: true))

    gateway.update_note(42, 'updated note')

    expect(Open3).to have_received(:capture2e).with('t', 'edit', '--id', '42', 'updated note')
  end

  it 'clears note via CLI with --clear when value is blank' do
    allow(Open3).to receive(:capture2e)
      .with('t', 'edit', '--id', '42', '--clear')
      .and_return(cmd_result(output: '', success: true))

    gateway.update_note(42, '')

    expect(Open3).to have_received(:capture2e).with('t', 'edit', '--id', '42', '--clear')
  end
end
