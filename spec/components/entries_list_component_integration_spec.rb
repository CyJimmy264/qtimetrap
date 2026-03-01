# frozen_string_literal: true

require 'spec_helper'

RSpec.describe QTimetrap::Components::EntriesListComponent do
  include_context :qt

  let(:parent) { QWidget.new }
  let(:on_entry_note_change) { instance_double(Proc, call: nil) }
  let(:component) { described_class.new(parent: parent, on_entry_note_change: on_entry_note_change) }
  let(:widget) { component.widget }

  after do
    parent.close if parent.respond_to?(:close)
    QApplication.process_events
  end

  it 'applies expand/collapse all recursively and renders unknown leaf type as empty node style' do
    component.render(entry_nodes)
    QApplication.process_events

    collapse_button.click
    QApplication.process_events
    expect(week_buttons).to all(satisfy { |button| normalized_text(button).lstrip.start_with?('▸') })

    expand_button.click
    QApplication.process_events
    expect(week_buttons).to all(satisfy { |button| normalized_text(button).lstrip.start_with?('▾') })

    unknown_leaf = descendants(parent).grep(QLabel).find { |label| label.object_name == 'entry_node_empty' }
    expect(unknown_leaf).not_to be_nil
  end

  it 'keeps branch nodes inside scroll viewport width for long labels' do
    parent.resize(920, 720)
    component.render(long_label_nodes)
    parent.show
    QApplication.process_events

    scroll_area = component.send(:scroll_area)
    host = component.send(:host)

    widest_branch = descendants(parent)
                    .grep(QPushButton)
                    .select { |button| button.object_name.start_with?('entry_node_') }
                    .map(&:width)
                    .max

    expect(host.width).to be <= scroll_area.width
    expect(widest_branch).to be <= scroll_area.width
  end

  it 'activates note input on click and commits only on Enter' do
    component.render(entry_nodes)
    QApplication.process_events

    note_input = descendants(parent).grep(QLineEdit).find { |input| input.object_name == 'entry_node_entry_note' }
    expect(note_input).not_to be_nil
    expect(note_input.text.to_s).to eq('test')
    expect(note_input.is_read_only).to be(true)

    component.send(:activate_entry_note_input, note_input)
    expect(note_input.is_read_only).to be(false)

    note_input.text = 'updated note'
    component.send(:handle_entry_note_key_press, note_input, 1, { a: Qt::Key_Return })

    expect(note_input.is_read_only).to be(true)
    expect(on_entry_note_change).to have_received(:call).with(1, 'updated note')
  end

  it 'deactivates note input on focus loss without committing' do
    component.render(entry_nodes)
    QApplication.process_events

    note_input = descendants(parent).grep(QLineEdit).find { |input| input.object_name == 'entry_node_entry_note' }
    component.send(:activate_entry_note_input, note_input)
    note_input.text = 'changed but not committed'

    component.send(:handle_entry_note_focus_out, note_input)

    expect(note_input.is_read_only).to be(true)
    expect(on_entry_note_change).not_to have_received(:call)
  end

  private

  def expand_button
    toolbar_button('entries_expand_all')
  end

  def collapse_button
    toolbar_button('entries_collapse_all')
  end

  def toolbar_button(name)
    descendants(parent).grep(QPushButton).find { |button| button.object_name == name }
  end

  def week_buttons
    descendants(parent).grep(QPushButton).select { |button| button.object_name == 'entry_node_week' }
  end

  def normalized_text(button)
    text = button.text.to_s.dup
    return text unless text.encoding == Encoding::BINARY

    text.force_encoding(Encoding::UTF_8)
  end

  def entry_nodes
    [
      {
        id: 'week:1',
        type: :week,
        label: 'Week Feb 23 - Mar 1  Total: 01:00:00',
        children: [
          {
            id: 'day:1',
            type: :day,
            label: 'Sun, Mar 1  Total: 01:00:00',
            children: [
              {
                id: 'project:1',
                type: :project,
                label: 'acme | core (1) 01:00:00',
                children: [
                  {
                    id: 'entry:1',
                    type: :entry,
                    entry_id: 1,
                    prefix: '10:00 - 11:00  01:00:00',
                    note: 'test',
                    label: '10:00 - 11:00  01:00:00  test',
                    children: []
                  }
                ]
              }
            ]
          }
        ]
      },
      {
        id: 'misc:1',
        type: :unknown_type,
        label: 'mystery node',
        children: []
      }
    ]
  end

  def long_label_nodes
    [
      {
        id: 'week:long',
        type: :week,
        label: "Week #{'X' * 300}",
        children: [
          {
            id: 'day:long',
            type: :day,
            label: "Day #{'Y' * 300}",
            children: [
              {
                id: 'project:long',
                type: :project,
                label: "Project #{'Z' * 300}",
                children: [
                  { id: 'entry:long', type: :entry, label: 'entry', children: [] }
                ]
              }
            ]
          }
        ]
      }
    ]
  end

  def descendants(widget)
    children = safe_children(widget)
    children + children.flat_map { |child| descendants(child) }
  end

  def safe_children(widget)
    return [] unless widget.respond_to?(:children)

    Array(widget.children).compact
  rescue NoMethodError
    []
  end
end
