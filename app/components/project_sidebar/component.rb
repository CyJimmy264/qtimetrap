# frozen_string_literal: true

module QTimetrap
  module ProjectSidebar
    # Displays project shortcuts and notifies on project selection.
    class Component
      include ArchiveToggleHelpers
      include LogoHelpers
      include ProjectSelectionHelpers
      include TaskHelpers

      attr_reader :widget

      def initialize(
        parent:,
        on_project_selected:,
        on_task_selected: nil,
        on_archive_mode_toggled: nil
      )
        @parent = parent
        @on_project_selected = on_project_selected
        @on_task_selected = on_task_selected
        @on_archive_mode_toggled = on_archive_mode_toggled
        initialize_selection_state
        build
      end

      def render(
        projects:,
        selected_project:,
        selected_projects: nil,
        tasks: [],
        selected_task: nil,
        archive_mode: false
      )
        values = Array(projects)
        refresh_project_state(values, selected_projects, selected_project)
        sync_project_buttons(values.size)
        buttons.each_with_index { |slot, index| render_slot(slot, values[index], index: index) }
        render_tasks(tasks: tasks, selected_project: selected_project, selected_task: selected_task)
        archive_toggle_button.set_checked(archive_mode)
      end

      private

      attr_reader :parent, :on_project_selected, :on_task_selected, :buttons, :buttons_layout, :task_buttons,
                  :task_buttons_layout, :tasks_heading, :on_archive_mode_toggled, :archive_toggle_button

      def build
        @widget = QWidget.new(parent)
        widget.set_object_name('sidebar_panel')
        layout = build_root_layout
        add_static_sidebar_sections(layout)
        @buttons_layout = build_buttons_layout
        layout.add_layout(buttons_layout)
        add_tasks_section(layout)
        layout.add_stretch(1)
        @archive_toggle_button = build_archive_toggle_button
        layout.add_widget(archive_toggle_button)
      end

      def render_slot(slot, project, index:)
        slot[:project] = project
        view = slot[:view]

        view.set_text(project[0, 24])
        view.set_disabled(false)
        view.set_checked(selected_project_indices.include?(index))
        view.show
      end

      def sync_project_buttons(target_count)
        while buttons.size < target_count
          button = build_project_button
          buttons_layout.add_widget(button)
          buttons << { view: button, project: nil }
        end

        while buttons.size > target_count
          slot = buttons.pop
          slot.fetch(:view).hide
        end
      end

      def build_root_layout
        QVBoxLayout.new(widget).tap do |layout|
          layout.set_contents_margins(12, 12, 12, 12)
          layout.set_spacing(8)
        end
      end

      def initialize_selection_state
        @buttons = []
        @selected_project_indices = []
        @last_project_anchor_index = nil
        @project_values = []
        @task_buttons = []
        @selected_task_indices = []
        @last_task_anchor_index = nil
        @task_values = []
      end

      def add_static_sidebar_sections(layout)
        layout.add_widget(build_logo)
        layout.add_widget(build_logo_spacer)
        layout.add_widget(build_heading)
      end

      def add_tasks_section(layout)
        @tasks_heading = build_tasks_heading
        tasks_heading.hide
        layout.add_widget(tasks_heading)
        @task_buttons_layout = build_buttons_layout
        layout.add_layout(task_buttons_layout)
      end

      def build_buttons_layout
        QVBoxLayout.new.tap do |layout|
          layout.set_contents_margins(0, 0, 0, 0)
          layout.set_spacing(8)
        end
      end

      def build_project_button
        QPushButton.new(widget).tap do |button|
          button.set_object_name('project_button')
          button.set_checkable(true)
          button.set_focus_policy(Qt::NoFocus)
          button.set_fixed_height(30)
          button.connect('clicked') { |_| on_button_clicked(button) }
        end
      end

      def on_button_clicked(button)
        index, item = selected_project_button(button)
        return unless index && item

        apply_project_selection(index)
        rerender_project_buttons
        on_project_selected.call(selected_project_values, item[:project])
      end

      def selected_project_button(button)
        index = buttons.index { |candidate| candidate[:view] == button }
        return [nil, nil] unless index

        item = buttons.fetch(index)
        return [nil, nil] unless item[:project]

        [index, item]
      end

      def rerender_project_buttons
        buttons.each_with_index { |slot, current_index| render_slot(slot, slot[:project], index: current_index) }
      end
    end
  end
end
