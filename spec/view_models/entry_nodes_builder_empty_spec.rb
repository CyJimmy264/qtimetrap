# frozen_string_literal: true

require 'spec_helper'

RSpec.describe QTimetrap::ViewModels::EntryNodesBuilder do
  it 'returns empty node when no entries match the filter' do
    nodes = described_class.new(entries: [], selected_project: 'acme').build

    expect(nodes).to eq(
      [
        {
          id: 'empty:acme',
          type: :empty,
          label: 'No entries for filter: acme',
          children: []
        }
      ]
    )
  end
end
