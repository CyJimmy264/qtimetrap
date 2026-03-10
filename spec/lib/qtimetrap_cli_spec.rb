# frozen_string_literal: true

require 'spec_helper'

RSpec.describe QTimetrap::CLI do
  it 'installs INT trap and requests shutdown on signal' do
    app = build_app_double
    window = build_window_double
    handler_ref = install_cli_traps(app, window)

    described_class.start([])

    expect_cli_startup(app, window)

    handler_ref.fetch(:handler).call
    expect(window).to have_received(:request_shutdown)
  end

  private

  def build_app_double
    instance_double(QApplication, exec: nil, dispose: nil)
  end

  def build_window_double
    instance_double(QTimetrap::Views::MainWindow, show: nil, request_shutdown: nil)
  end

  def install_cli_traps(app, window)
    container = instance_double(QTimetrap::Container)
    allow(QTimetrap::Application).to receive_messages(boot!: app, container: container)
    allow(container).to receive(:fetch).with(:main_window).and_return(window)

    handler_ref = {}
    allow(Signal).to receive(:trap) do |signal, _previous = nil, &block|
      handler_ref[:handler] = block if signal == 'INT' && block
      'old_handler'
    end
    handler_ref
  end

  def expect_cli_startup(app, window)
    expect(window).to have_received(:show)
    expect(app).to have_received(:exec)
    expect(app).to have_received(:dispose)
    expect(Signal).to have_received(:trap).with('INT')
    expect(Signal).to have_received(:trap).with('INT', 'old_handler')
  end
end
