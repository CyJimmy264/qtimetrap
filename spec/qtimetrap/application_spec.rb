# frozen_string_literal: true

require 'spec_helper'

RSpec.describe QTimetrap::Application do
  around do |example|
    original_container = described_class.instance_variable_get(:@container)
    original_qt_app = described_class.instance_variable_get(:@qt_app)

    described_class.instance_variable_set(:@container, nil)
    described_class.instance_variable_set(:@qt_app, nil)

    example.run
  ensure
    described_class.instance_variable_set(:@container, original_container)
    described_class.instance_variable_set(:@qt_app, original_qt_app)
  end

  it 'memoizes container instance' do
    container = stub_container_instance
    described_class.container
    described_class.container
    expect_container_to_be_memoized(container)
  end

  it 'keeps qt_app nil when QApplication boot raises' do
    allow(QApplication).to receive(:new).and_raise(StandardError, 'qt init failed')

    described_class.setup_qt

    expect(described_class.qt_app).to be_nil
  end

  it 'configures QApplication identity for desktop integration' do
    stub_qt_application_identity
    described_class.setup_qt
    expect_qt_application_identity
  end

  private

  def stub_container_instance
    instance_double(QTimetrap::Container).tap do |container|
      allow(QTimetrap::Container).to receive(:new).and_return(container)
    end
  end

  def expect_container_to_be_memoized(container)
    expect(described_class.container).to equal(container)
    expect(QTimetrap::Container).to have_received(:new).once
  end

  def stub_qt_application_identity
    allow(QApplication).to receive(:new).and_return(instance_double(QApplication))
    allow(QApplication).to receive(:set_application_name)
    allow(QApplication).to receive(:set_desktop_file_name)
    allow(QApplication).to receive(:set_application_display_name)
    allow(QApplication).to receive(:set_organization_name)
  end

  def expect_qt_application_identity
    expect(QApplication).to have_received(:set_application_name).with('qtimetrap')
    expect(QApplication).to have_received(:set_desktop_file_name).with('qtimetrap')
    expect(QApplication).to have_received(:set_application_display_name).with('QTimetrap')
    expect(QApplication).to have_received(:set_organization_name).with('mveynberg')
  end
end
