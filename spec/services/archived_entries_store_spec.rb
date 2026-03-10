# frozen_string_literal: true

require 'spec_helper'
require 'tmpdir'

RSpec.describe QTimetrap::Services::ArchivedEntriesStore do
  let(:path) { File.join(Dir.mktmpdir, 'archived_entries.yml') }
  let(:store) { described_class.new(path: path) }

  it 'persists archived ids and reads them back' do
    expect(store.archived_ids).to eq([])

    store.archive(42)
    store.archive('7')

    expect_archived_state(ids: [7, 42], archived: [42, '7'], missing: [99])
  end

  it 'ignores invalid archive ids' do
    expect { store.archive('bad') }.not_to raise_error
    expect(store.archived_ids).to eq([])
  end

  private

  def expect_archived_state(ids:, archived:, missing:)
    expect(store.archived_ids).to eq(ids)
    expect_entries_archived(archived)
    expect_entries_missing(missing)
  end

  def expect_entries_archived(values)
    values.each { |value| expect(store.archived?(value)).to be(true) }
  end

  def expect_entries_missing(values)
    values.each { |value| expect(store.archived?(value)).to be(false) }
  end
end
