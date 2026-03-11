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
    attempts, timer, context = bootstrap_tick_state
    host.send(:tick_initial_reposition, attempts: attempts, timer: timer, context: context)
    expect_bootstrap_tick_result(attempts, timer, context)
  end

  private

  def bootstrap_tick_state
    attempts = { count: 3 }
    timer = instance_double(QTimer, stop: nil, delete_later: nil)
    context = { splitter: :splitter, sidebar_widget: :sidebar, button: :button, zone: :zone }
    [attempts, timer, context]
  end

  def expect_bootstrap_tick_result(attempts, timer, context)
    expect(host.repositions).to eq([context])
    expect(attempts[:count]).to eq(4)
    expect(timer).to have_received(:stop)
    expect(timer).to have_received(:delete_later)
  end
end
