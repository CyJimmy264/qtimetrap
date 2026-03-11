# frozen_string_literal: true

require 'spec_helper'

RSpec.describe QTimetrap::Views::MainWindow do
  include_context :main_window_qt_boot
  include_context :main_window_cleanup

  let(:entry_nodes) do
    [
      build_week_node('week:2026-02-23', 'Week Feb 23 - Mar 1  Total: 01:00:00'),
      build_week_node('week:2026-02-16', 'Week Feb 16 - Feb 22  Total: 02:00:00'),
      build_week_node('week:2026-02-09', 'Week Feb 9 - Feb 15  Total: 03:00:00'),
      build_week_node('week:2026-02-02', 'Week Feb 2 - Feb 8  Total: 04:00:00'),
      build_week_node('week:2026-01-26', 'Week Jan 26 - Feb 1  Total: 05:00:00')
    ]
  end

  include_context :main_window_setup

  it 'keeps week nodes interactive during top-down/bottom-up x10 toggles' do
    main_window.send(:render!)
    repeat_week_toggle_cycles(10)
    expect_week_buttons_expanded
  end

  private

  def build_week_node(id, label)
    {
      id: id,
      type: :week,
      label: label,
      children: [
        {
          id: "#{id}:day",
          type: :day,
          label: 'Sat, Feb 28  Total: 01:00:00',
          children: [
            {
              id: "#{id}:project",
              type: :project,
              label: 'acme | core (1) 01:00:00',
              children: [
                {
                  id: "#{id}:entry",
                  type: :entry,
                  label: '10:00 - 11:00  01:00:00  test',
                  children: []
                }
              ]
            }
          ]
        }
      ]
    }
  end

  def week_buttons_top_down
    widgets_of_type(qt_window, QPushButton)
      .select { |button| button.object_name == 'entry_node_week' }
      .sort_by(&:y)
  end

  def week_buttons_bottom_up
    week_buttons_top_down.reverse
  end

  def click_button(button)
    button.click
    QApplication.process_events
  end

  def repeat_week_toggle_cycles(count)
    count.times do
      collapse_week_buttons
      expand_week_buttons
    end
  end

  def collapse_week_buttons
    week_buttons_top_down.each { |button| click_button(button) }
    expect(week_buttons_top_down).to all(satisfy { |button| collapsed_button?(button) })
  end

  def expand_week_buttons
    week_buttons_bottom_up.each { |button| click_button(button) }
  end

  def expect_week_buttons_expanded
    expect(week_buttons_top_down).to all(satisfy { |button| expanded_button?(button) })
  end

  def collapsed_button?(button)
    normalized_text(button).lstrip.start_with?('▸')
  end

  def expanded_button?(button)
    normalized_text(button).lstrip.start_with?('▾')
  end

  def normalized_text(button)
    text = button.text.to_s.dup
    return text unless text.encoding == Encoding::BINARY

    text.force_encoding(Encoding::UTF_8)
  end
end
