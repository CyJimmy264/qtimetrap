# frozen_string_literal: true

require 'spec_helper'

RSpec.describe QTimetrap::Application do
  before do
    described_class.instance_variable_set(:@container, nil)
    described_class.instance_variable_set(:@qt_app, nil)
  end

  it 'memoizes container instance' do
    container = instance_double(QTimetrap::Container)
    allow(QTimetrap::Container).to receive(:new).and_return(container)

    first = described_class.container
    second = described_class.container

    expect(first).to equal(container)
    expect(second).to equal(container)
    expect(QTimetrap::Container).to have_received(:new).once
  end

  it 'keeps qt_app nil when QApplication boot raises' do
    allow(QApplication).to receive(:new).and_raise(StandardError, 'qt init failed')

    described_class.setup_qt

    expect(described_class.qt_app).to be_nil
  end
end
