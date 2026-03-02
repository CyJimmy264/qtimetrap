# frozen_string_literal: true

module QTimetrap
  module ProjectSidebar
    # Displays project shortcuts and notifies on project selection.
    class Component
      include LogoHelpers
      include TaskHelpers

      attr_reader :widget

      def initialize(parent:, on_project_selected:, on_task_selected: nil)
        @parent = parent
        @on_project_selected = on_project_selected
        @on_task_selected = on_task_selected
        @buttons = []
        @task_buttons = []
        @selected_task_indices = []
        @last_task_anchor_index = nil
        @task_values = []

        build
      end

      def render(projects:, selected_project:, tasks: [], selected_task: nil)
        values = Array(projects)
        sync_project_buttons(values.size)
        buttons.each_with_index { |slot, index| render_slot(slot, values[index], selected_project) }
        render_tasks(tasks: tasks, selected_project: selected_project, selected_task: selected_task)
      end

      private

      attr_reader :parent, :on_project_selected, :on_task_selected, :buttons, :buttons_layout, :task_buttons,
                  :task_buttons_layout, :tasks_heading

      def build
        @widget = QWidget.new(parent)
        widget.set_object_name('sidebar_panel')
        layout = build_root_layout
        add_static_sidebar_sections(layout)
        @buttons_layout = build_buttons_layout
        layout.add_layout(buttons_layout)
        add_tasks_section(layout)
        layout.add_stretch(1)
      end

      def render_slot(slot, project, selected_project)
        slot[:project] = project
        view = slot[:view]

        view.set_text(project[0, 24])
        view.set_disabled(false)
        view.set_checked(project == selected_project)
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
          button.set_fixed_height(30)
          button.connect('clicked') { |_| on_button_clicked(button) }
        end
      end

      def on_button_clicked(button)
        item = buttons.find { |candidate| candidate[:view] == button }
        return unless item && item[:project]

        on_project_selected.call(item[:project])
      end
    end
  end
end
