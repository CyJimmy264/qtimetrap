# frozen_string_literal: true

module QTimetrap
  module ProjectSidebar
    # Sidebar header/logo construction helpers.
    module LogoHelpers
      private

      def build_logo
        QWidget.new(widget).tap do |container|
          container.object_name = 'sidebar_logo'
          layout = QHBoxLayout.new(container)
          layout.set_contents_margins(0, 0, 0, 0)
          layout.spacing = 8
          layout.add_stretch(1)
          layout.add_widget(build_logo_icon(container))
          layout.add_widget(build_logo_text(container))
          layout.add_stretch(1)
        end
      end

      def build_logo_icon(parent_widget)
        QLabel.new(parent_widget).tap do |label|
          label.object_name = 'sidebar_logo_icon'
          label.alignment = Qt::AlignCenter
          label.set_fixed_size(66, 66)
          icon_path = File.join(Application.root, 'app', 'assets', 'icons', 'qtimetrap-icon-128.png')
          label.text = "<img src='#{icon_path}' width='64' height='64'/>"
        end
      end

      def build_logo_text(parent_widget)
        QLabel.new(parent_widget).tap do |label|
          label.object_name = 'sidebar_logo_text'
          label.alignment = Qt::AlignCenter
          label.text = 'QTimetrap'
        end
      end

      def build_logo_spacer
        QWidget.new(widget).tap { |spacer| spacer.fixed_height = 6 }
      end

      def build_heading
        QLabel.new(widget).tap do |label|
          label.object_name = 'sidebar_heading'
          label.alignment = Qt::AlignCenter
          label.text = 'PROJECTS'
        end
      end
    end
  end
end
