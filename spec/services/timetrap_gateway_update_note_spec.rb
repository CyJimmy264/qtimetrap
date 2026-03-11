# frozen_string_literal: true

require 'spec_helper'

RSpec.describe QTimetrap::Services::TimetrapGateway do
  subject(:gateway) { described_class.new }

  it 'updates note via API when timetrap API is available' do
    entry = stub_note_api_entry

    gateway.update_note(42, 'updated note')

    expect_note_update(entry, 'updated note')
  end

  it 'raises when API entry is not found by id' do
    stub_note_api_constants
    allow(Timetrap::Entry).to receive(:[]).with(42).and_return(nil)

    expect { gateway.update_note(42, 'updated note') }
      .to raise_error(TypeError, /Unsupported entry lookup result: NilClass/)
  end

  it 'updates note via CLI when API is unavailable' do
    stub_const('Timetrap', Module.new)
    stub_cli_note_update('updated note')
    gateway.update_note(42, 'updated note')
    expect_cli_note_update('updated note')
  end

  it 'clears note via CLI with --clear when value is blank' do
    stub_const('Timetrap', Module.new)
    stub_cli_note_update('--clear')
    gateway.update_note(42, '')
    expect_cli_note_update('--clear')
  end

  private

  def stub_note_api_entry
    stub_note_api_constants
    entry = instance_double(note_entry_class)
    allow(Timetrap::Entry).to receive(:[]).with(42).and_return(entry)
    allow(entry).to receive(:note=)
    allow(entry).to receive(:save)
    entry
  end

  def stub_note_api_constants
    stub_const('Timetrap', Module.new)
    Timetrap.const_set(:Entry, note_entry_class)
    Timetrap.const_set(:Timer, Class.new)
  end

  def note_entry_class
    @note_entry_class ||= Class.new do
      attr_accessor :note

      def save; end
    end
  end

  def expect_note_update(entry, value)
    expect(Timetrap::Entry).to have_received(:[]).with(42)
    expect(entry).to have_received(:note=).with(value)
    expect(entry).to have_received(:save)
  end

  def stub_cli_note_update(argument)
    allow(Open3).to receive(:capture2e)
      .with('t', 'edit', '--id', '42', argument)
      .and_return(cmd_result(output: '', success: true))
  end

  def expect_cli_note_update(argument)
    expect(Open3).to have_received(:capture2e).with('t', 'edit', '--id', '42', argument)
  end
end
