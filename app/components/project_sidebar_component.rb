# frozen_string_literal: true

module QTimetrap
  module Components
    class ProjectSidebarComponent
      SLOT_COUNT = 14

      attr_reader :widget

      def initialize(parent:, on_project_selected:)
        @parent = parent
        @on_project_selected = on_project_selected
        @buttons = []

        build
      end

      def render(projects:, selected_project:)
        values = projects.first(SLOT_COUNT)

        buttons.each_with_index do |slot, index|
          project = values[index]
          slot[:project] = project
          view = slot[:view]

          if project
            view.set_text(project[0, 24])
            view.set_disabled(0)
            view.set_checked(project == selected_project ? 1 : 0)
          else
            view.set_text('')
            view.set_disabled(1)
            view.set_checked(0)
          end
        end
      end

      private

      attr_reader :parent, :on_project_selected, :buttons

      def build
        @widget = QWidget.new(parent)
        set_name(widget, 'sidebar_panel')

        layout = QVBoxLayout.new(widget)
        layout.set_contents_margins(12, 12, 12, 12)
        layout.set_spacing(8)

        logo = QLabel.new(widget)
        set_name(logo, 'sidebar_logo')
        logo.set_alignment(Qt::AlignCenter)
        logo.set_text('QTimetrap')
        layout.add_widget(logo)

        spacer = QWidget.new(widget)
        spacer.set_fixed_height(220)
        layout.add_widget(spacer)

        heading = QLabel.new(widget)
        set_name(heading, 'sidebar_heading')
        heading.set_alignment(Qt::AlignCenter)
        heading.set_text('PROJECTS')
        layout.add_widget(heading)

        SLOT_COUNT.times do
          button = QPushButton.new(widget)
          set_name(button, 'project_button')
          button.set_checkable(1)
          button.set_fixed_height(30)
          button.connect('clicked') { |_| on_button_clicked(button) }
          layout.add_widget(button)
          buttons << { view: button, project: nil }
        end

        layout.add_stretch(1)
      end

      def on_button_clicked(button)
        item = buttons.find { |candidate| candidate[:view] == button }
        return unless item && item[:project]

        on_project_selected.call(item[:project])
      end

      def set_name(widget, value)
        if widget.respond_to?(:set_object_name)
          widget.set_object_name(value)
        elsif widget.respond_to?(:setObjectName)
          widget.setObjectName(value)
        end
      end
    end
  end
end
