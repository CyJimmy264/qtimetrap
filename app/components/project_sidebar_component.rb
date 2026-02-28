# frozen_string_literal: true

module QTimetrap
  module Components
    class ProjectSidebarComponent
      SLOT_COUNT = 14

      def initialize(parent:, x:, y:, width:, height:, on_project_selected:)
        @parent = parent
        @on_project_selected = on_project_selected
        @buttons = []

        build_frame
        relayout(x: x, y: y, width: width, height: height)
      end

      def relayout(x:, y:, width:, height:)
        panel.set_geometry(x, y, width, height)
        logo.set_geometry(x + 18, y + 12, width - 36, 34)
        heading.set_geometry(x + 16, y + 286, width - 32, 26)

        buttons.each_with_index do |slot, index|
          row_y = y + 316 + (index * 34)
          slot[:view].set_geometry(x + 12, row_y, width - 24, 30)
        end
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

      attr_reader :parent, :on_project_selected, :buttons, :panel, :logo, :heading

      def build_frame
        @panel = QLabel.new(parent)
        set_name(panel, 'sidebar_panel')

        @logo = QLabel.new(parent)
        set_name(logo, 'sidebar_logo')
        logo.set_alignment(Qt::AlignCenter)
        logo.set_text('QTimetrap')

        @heading = QLabel.new(parent)
        set_name(heading, 'sidebar_heading')
        heading.set_alignment(Qt::AlignCenter)
        heading.set_text('PROJECTS')

        SLOT_COUNT.times do
          button = QPushButton.new(parent)
          set_name(button, 'project_button')
          button.set_checkable(1)
          button.connect('clicked') { |_| on_button_clicked(button) }
          buttons << { view: button, project: nil }
        end
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
