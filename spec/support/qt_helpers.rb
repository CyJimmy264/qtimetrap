# frozen_string_literal: true

RSpec.shared_context :qt do
  before(:all) do
    @qt_app = QTimetrap::Application.boot!
  end

  after(:all) do
    QApplication.process_events
    @qt_app&.dispose if @qt_app.respond_to?(:dispose)
    QTimetrap::Application.instance_variable_set(:@qt_app, nil)
  end

  def qt_app
    @qt_app
  end

  def widget_descendants(widget)
    children = Array(widget.children).compact
    children + children.flat_map { |child| widget_descendants(child) }
  end

  def find_widget(root, object_name)
    widget_descendants(root).find { |widget| widget.respond_to?(:object_name) && widget.object_name == object_name }
  end
end

RSpec::Matchers.define :have_child_with_text do |expected|
  match do |widget|
    queue = [widget]
    all = []
    until queue.empty?
      current = queue.shift
      all << current
      queue.concat(Array(current.children).compact)
    end
    all.any? do |child|
      child.respond_to?(:text) && child.text.to_s == expected
    end
  end
end
