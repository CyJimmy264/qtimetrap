# frozen_string_literal: true

module QTimetrap
  module ProjectSidebar
    # Project button rendering and interaction behavior for the sidebar.
    module ProjectButtonHelpers
      private

      def render_projects(projects:, selection:)
        refresh_project_state(projects, selection.fetch(:selected_projects), selection.fetch(:selected_project))
        sync_project_buttons(projects.size)
        rerender_project_buttons(projects)
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

      def render_slot(slot, project, index:)
        slot[:project] = project
        view = slot[:view]

        view.set_text(project[0, 24])
        view.set_disabled(false)
        view.set_checked(selected_project_indices.include?(index))
        view.show
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
        rerender_project_buttons(project_values)
        on_project_selected.call(selected_project_values, item[:project])
      end

      def selected_project_button(button)
        index = buttons.index { |candidate| candidate[:view] == button }
        return [nil, nil] unless index

        item = buttons.fetch(index)
        return [nil, nil] unless item[:project]

        [index, item]
      end

      def rerender_project_buttons(projects)
        buttons.each_with_index { |slot, index| render_slot(slot, projects[index], index: index) }
      end
    end
  end
end
