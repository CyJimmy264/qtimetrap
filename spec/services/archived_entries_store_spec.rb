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

    expect(store.archived_ids).to eq([7, 42])
    expect(store.archived?(42)).to be(true)
    expect(store.archived?('7')).to be(true)
    expect(store.archived?(99)).to be(false)
  end

  it 'ignores invalid archive ids' do
    expect { store.archive('bad') }.not_to raise_error
    expect(store.archived_ids).to eq([])
  end
end
