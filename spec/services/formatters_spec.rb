# frozen_string_literal: true

require 'spec_helper'

RSpec.describe QTimetrap::Services::Formatters do
  describe '.seconds_to_hms' do
    it 'formats standard values' do
      expect(described_class.seconds_to_hms(3661)).to eq('01:01:01')
    end

    it 'clamps negative values to zero' do
      expect(described_class.seconds_to_hms(-4)).to eq('00:00:00')
    end
  end

  describe '.time_range' do
    it 'renders running label when end is absent' do
      expect(described_class.time_range(running_entry)).to eq('09:10 - running')
    end
  end

  private

  def running_entry
    QTimetrap::Models::TimeEntry.new(
      id: 1,
      note: 'n',
      sheet: 'p|t',
      start_time: Time.new(2026, 2, 27, 9, 10, 0, '+00:00'),
      end_time: nil
    )
  end
end
