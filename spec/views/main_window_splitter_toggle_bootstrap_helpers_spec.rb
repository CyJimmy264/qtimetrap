# frozen_string_literal: true

require 'spec_helper'

RSpec.describe QTimetrap::Views::MainWindowSplitterToggleBootstrapHelpers do
  subject(:host) { host_class.new }

  let(:host_class) do
    Class.new do
      include QTimetrap::Views::MainWindowSplitterToggleBootstrapHelpers

      attr_reader :repositions

      def initialize
        @repositions = []
      end

      def reposition_toggle_affordance(**context)
        @repositions << context
      end
    end
  end

  it 'stops and deletes bootstrap timer after fourth attempt' do
    attempts = { count: 3 }
    timer = instance_double(QTimer)
    context = { splitter: :splitter, sidebar_widget: :sidebar, button: :button, zone: :zone }
    allow(timer).to receive(:stop)
    allow(timer).to receive(:delete_later)

    host.send(:tick_initial_reposition, attempts: attempts, timer: timer, context: context)

    expect(host.repositions).to eq([context])
    expect(attempts[:count]).to eq(4)
    expect(timer).to have_received(:stop)
    expect(timer).to have_received(:delete_later)
  end
end
