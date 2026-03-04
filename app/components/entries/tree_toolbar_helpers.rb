# frozen_string_literal: true

module QTimetrap
  module Entries
    # Toolbar builders for entries tree controls and time-range filters.
    module TreeToolbarHelpers
      private

      def build_toolbar(parent_widget:)
        toolbar = QWidget.new(parent_widget)
        toolbar.set_object_name('entries_toolbar')
        layout = build_toolbar_layout(toolbar)
        add_tree_toolbar_buttons(layout, toolbar)
        add_time_filter_controls(layout, toolbar)
        set_initial_filter_ui_state
        layout.add_stretch(1)
        toolbar
      end

      def build_toolbar_layout(toolbar)
        QHBoxLayout.new(toolbar).tap do |layout|
          layout.set_contents_margins(0, 0, 0, 0)
          layout.set_spacing(8)
        end
      end

      def add_tree_toolbar_buttons(layout, toolbar)
        add_toolbar_button(layout, toolbar, 'entries_expand_all', 'EXPAND ALL') { expand_all! }
        add_toolbar_button(layout, toolbar, 'entries_collapse_all', 'COLLAPSE ALL') { collapse_all! }
        layout.add_spacing(8)
      end

      def add_toolbar_button(layout, toolbar, name, text, &)
        layout.add_widget(build_toolbar_button(toolbar, name, text, &))
      end

      def add_time_filter_controls(layout, toolbar)
        @time_filter_from_toggle = add_filter_control(
          layout: layout,
          toolbar: toolbar,
          toggle_name: 'entries_time_filter_from_toggle',
          toggle_text: 'FROM',
          input_name: 'entries_time_filter_from'
        )
        @time_filter_to_toggle = add_filter_control(
          layout: layout,
          toolbar: toolbar,
          toggle_name: 'entries_time_filter_to_toggle',
          toggle_text: 'TO',
          input_name: 'entries_time_filter_to'
        )
      end

      def add_filter_control(layout:, toolbar:, toggle_name:, toggle_text:, input_name:)
        toggle = build_filter_toggle(toolbar, toggle_name, toggle_text)
        layout.add_widget(toggle)
        input = build_filter_input(toolbar, input_name)
        layout.add_widget(input)
        assign_filter_input(toggle_name, input)
        toggle
      end

      def assign_filter_input(toggle_name, input)
        if toggle_name == 'entries_time_filter_from_toggle'
          @time_filter_from_input = input
        else
          @time_filter_to_input = input
        end
      end

      def build_toolbar_button(parent_widget, name, text)
        build_button(parent_widget, name, text, 136, 28).tap { |button| button.connect('clicked') { |_| yield } }
      end

      def build_filter_toggle(parent_widget, name, text)
        QCheckBox.new(parent_widget).tap do |checkbox|
          checkbox.set_object_name(name)
          checkbox.set_text(text)
          checkbox.set_focus_policy(Qt::NoFocus)
          checkbox.set_fixed_height(28)
          checkbox.connect('clicked') { |_| on_filter_toggle_changed }
        end
      end

      def build_filter_input(parent_widget, name)
        QDateTimeEdit.new(parent_widget).tap do |input|
          input.set_object_name(name)
          input.set_focus_policy(Qt::ClickFocus)
          input.set_fixed_width(172)
          input.set_calendar_popup(true)
          input.set_display_format('yyyy-MM-dd HH:mm')
          input.set_date_time(Time.now)
          input.connect('dateTimeChanged(QDateTime)') { |_| schedule_time_range_filter_changed }
        end
      end
    end
  end
end
