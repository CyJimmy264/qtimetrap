# frozen_string_literal: true

module QTimetrap
  module Components
    # Displays project shortcuts and notifies on project selection.
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
        buttons.each_with_index { |slot, index| render_slot(slot, values[index], selected_project) }
      end

      private

      attr_reader :parent, :on_project_selected, :buttons

      def build
        @widget = QWidget.new(parent)
        widget.set_object_name('sidebar_panel')

        layout = QVBoxLayout.new(widget)
        layout.set_contents_margins(12, 12, 12, 12)
        layout.set_spacing(8)

        layout.add_widget(build_logo)
        layout.add_widget(build_logo_spacer)
        layout.add_widget(build_heading)
        add_project_buttons(layout)
        layout.add_stretch(1)
      end

      def render_slot(slot, project, selected_project)
        slot[:project] = project
        view = slot[:view]
        return render_empty_slot(view) unless project

        view.set_text(project[0, 24])
        view.set_disabled(false)
        view.set_checked(project == selected_project)
      end

      def render_empty_slot(view)
        view.set_text('')
        view.set_disabled(true)
        view.set_checked(false)
      end

      def build_logo
        QWidget.new(widget).tap do |container|
          container.set_object_name('sidebar_logo')
          layout = QHBoxLayout.new(container)
          layout.set_contents_margins(0, 0, 0, 0)
          layout.set_spacing(8)
          layout.add_stretch(1)
          layout.add_widget(build_logo_icon(container))
          layout.add_widget(build_logo_text(container))
          layout.add_stretch(1)
        end
      end

      def build_logo_icon(parent_widget)
        QLabel.new(parent_widget).tap do |label|
          label.set_object_name('sidebar_logo_icon')
          label.set_alignment(Qt::AlignCenter)
          label.set_fixed_size(64, 64)
          icon_path = File.join(Application.root, 'app', 'assets', 'icons', 'qtimetrap-icon-128.png')
          label.set_text("<img src='#{icon_path}' width='64' height='64'/>")
        end
      end

      def build_logo_text(parent_widget)
        QLabel.new(parent_widget).tap do |label|
          label.set_object_name('sidebar_logo_text')
          label.set_alignment(Qt::AlignCenter)
          label.set_text('QTimetrap')
        end
      end

      def build_logo_spacer
        QWidget.new(widget).tap { |spacer| spacer.set_fixed_height(220) }
      end

      def build_heading
        QLabel.new(widget).tap do |label|
          label.set_object_name('sidebar_heading')
          label.set_alignment(Qt::AlignCenter)
          label.set_text('PROJECTS')
        end
      end

      def add_project_buttons(layout)
        SLOT_COUNT.times do
          button = build_project_button
          layout.add_widget(button)
          buttons << { view: button, project: nil }
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
