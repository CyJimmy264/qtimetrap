# frozen_string_literal: true

require 'spec_helper'

RSpec.describe QTimetrap::ViewModels::MainViewModel do
  include_context :main_view_model_setup

  it 'loads entries and keeps ALL selected by default' do
    view_model.refresh!
    expect(view_model.entries.size).to eq(2)
    expect(view_model.selected_project).to eq('* ALL')
  end

  it 'returns sorted project names with ALL first' do
    view_model.refresh!
    expect(view_model.project_names).to eq(['* ALL', 'acme', 'internal'])
  end

  it 'filters by selected project' do
    view_model.refresh!
    view_model.select_project('acme')
    expect(view_model.filtered_entries.map(&:project)).to eq(['acme'])
  end
end
