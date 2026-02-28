# frozen_string_literal: true

require 'spec_helper'

RSpec.describe QTimetrap::Services::TimetrapGateway do
  subject(:gateway) { described_class.new }

  describe '#entries' do
    context 'with API available' do
      before do
        stub_const('Timetrap', Module.new)

        entry_class = Class.new
        timer_class = Class.new
        Timetrap.const_set(:Entry, entry_class)
        Timetrap.const_set(:Timer, timer_class)

        first_entry = instance_double('TimetrapEntry', id: 1, note: 'note 1', sheet: 'acme|core')
        second_entry = instance_double('TimetrapEntry', id: 2, note: 'note 2', sheet: 'internal|ops')

        allow(first_entry).to receive(:[]).with(:start).and_return(Time.new(2026, 2, 28, 10, 0, 0, '+00:00'))
        allow(first_entry).to receive(:[]).with(:end).and_return(Time.new(2026, 2, 28, 11, 0, 0, '+00:00'))
        allow(second_entry).to receive(:[]).with(:start).and_return(Time.new(2026, 2, 28, 12, 0, 0, '+00:00'))
        allow(second_entry).to receive(:[]).with(:end).and_return(nil)

        relation = instance_double('EntryRelation', all: [first_entry, second_entry])
        allow(Timetrap::Entry).to receive(:order).with(:start).and_return(relation)
      end

      it 'maps timetrap entries to model objects' do
        entries = gateway.entries

        expect(entries.size).to eq(2)
        expect(entries.first).to be_a(QTimetrap::Models::TimeEntry)
        expect(entries.first.project).to eq('acme')
        expect(entries.last.task).to eq('ops')
      end
    end

    context 'with CLI fallback' do
      before do
        allow(gateway).to receive(:api_available?).and_return(false)
      end

      it 'parses JSON output' do
        json = <<~JSON
          [{"id":1,"note":"n1","sheet":"acme|core","start":"2026-02-28 10:00:00 +0000","end":"2026-02-28 11:00:00 +0000"}]
        JSON
        allow(Open3).to receive(:capture2e).with('t', 'display', '--format', 'json').and_return(cmd_result(output: json, success: true))

        entries = gateway.entries

        expect(entries.size).to eq(1)
        expect(entries.first.project).to eq('acme')
      end

      it 'returns empty array for invalid JSON' do
        allow(Open3).to receive(:capture2e).with('t', 'display', '--format', 'json').and_return(cmd_result(output: 'not-json', success: true))

        expect(gateway.entries).to eq([])
      end
    end
  end

  describe '#active_started_at' do
    context 'with API available' do
      before do
        stub_const('Timetrap', Module.new)
        Timetrap.const_set(:Entry, Class.new)
        timer_class = Class.new
        Timetrap.const_set(:Timer, timer_class)
      end

      it 'returns start time from active entry' do
        start_time = Time.new(2026, 2, 28, 9, 0, 0, '+00:00')
        allow(Timetrap::Timer).to receive(:active_entry).and_return({ start: start_time })

        expect(gateway.active_started_at).to eq(start_time)
      end

      it 'returns nil when no active entry' do
        allow(Timetrap::Timer).to receive(:active_entry).and_return(nil)

        expect(gateway.active_started_at).to be_nil
      end
    end

    context 'with CLI fallback' do
      before do
        allow(gateway).to receive(:api_available?).and_return(false)
      end

      it 'parses started_at from timetrap now output' do
        out = "2026-02-28 09:30:00 +0000 some text"
        allow(Open3).to receive(:capture2e).with('t', 'now').and_return(cmd_result(output: out, success: true))

        result = gateway.active_started_at

        expect(result).to be_a(Time)
        expect(result.strftime('%Y-%m-%d %H:%M:%S %z')).to eq('2026-02-28 09:30:00 +0000')
      end

      it 'returns nil on command failure' do
        allow(Open3).to receive(:capture2e).with('t', 'now').and_return(cmd_result(output: 'err', success: false))

        expect(gateway.active_started_at).to be_nil
      end
    end
  end

  describe '#start and #stop' do
    context 'with API available' do
      before do
        stub_const('Timetrap', Module.new)
        Timetrap.const_set(:Entry, Class.new)
        timer_class = Class.new
        Timetrap.const_set(:Timer, timer_class)
      end

      it 'delegates start to timer API' do
        allow(Timetrap::Timer).to receive(:start)

        gateway.start('focus')

        expect(Timetrap::Timer).to have_received(:start).with('focus')
      end

      it 'delegates stop to timer API with active entry' do
        active = { id: 77 }
        allow(Timetrap::Timer).to receive(:active_entry).and_return(active)
        allow(Timetrap::Timer).to receive(:stop)

        gateway.stop

        expect(Timetrap::Timer).to have_received(:stop).with(active)
      end
    end

    context 'with CLI fallback' do
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
  end
end
