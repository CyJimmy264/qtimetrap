# frozen_string_literal: true

require 'spec_helper'

RSpec.describe QTimetrap::CLI do
  it 'installs INT trap and requests shutdown on signal' do
    app = instance_double(QApplication, exec: nil, dispose: nil)
    window = instance_double(QTimetrap::Views::MainWindow, show: nil, request_shutdown: nil)
    container = instance_double(QTimetrap::Container)

    allow(QTimetrap::Application).to receive(:boot!).and_return(app)
    allow(QTimetrap::Application).to receive(:container).and_return(container)
    allow(container).to receive(:fetch).with(:main_window).and_return(window)

    handler = nil
    allow(Signal).to receive(:trap) do |signal, _previous = nil, &block|
      handler = block if signal == 'INT' && block
      'old_handler'
    end

    described_class.start([])

    expect(window).to have_received(:show)
    expect(app).to have_received(:exec)
    expect(app).to have_received(:dispose)
    expect(Signal).to have_received(:trap).with('INT')
    expect(Signal).to have_received(:trap).with('INT', 'old_handler')

    handler.call
    expect(window).to have_received(:request_shutdown)
  end
end
