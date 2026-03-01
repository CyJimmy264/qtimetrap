# frozen_string_literal: true

require 'spec_helper'

RSpec.describe QTimetrap::ViewModels::MainViewModel do
  include_context :main_view_model_setup

  it 'updates note in gateway and in local entry cache' do
    view_model.refresh!

    view_model.update_entry_note(entry_today.id, 'new note')

    expect(gateway).to have_received(:update_note).with(entry_today.id, 'new note')
    updated = view_model.entries.find { |entry| entry.id == entry_today.id }
    expect(updated.note).to eq('new note')
  end
end
