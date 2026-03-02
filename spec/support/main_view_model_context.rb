# frozen_string_literal: true

RSpec.shared_context :main_view_model_setup do
  let(:gateway) { instance_double(QTimetrap::Services::TimetrapGateway) }
  let(:view_model) { QTimetrap::ViewModels::MainViewModel.new(gateway: gateway) }
  let(:entry_today) do
    QTimetrap::Models::TimeEntry.new(id: 1, note: 'build widget', sheet: 'acme|core',
                                     start_time: Time.now - 3600, end_time: Time.now)
  end
  let(:entry_other_project) do
    QTimetrap::Models::TimeEntry.new(id: 2, note: 'bugfix', sheet: 'internal|ops',
                                     start_time: Time.now - 1800, end_time: Time.now)
  end

  before do
    allow(gateway).to receive(:active_started_at).and_return(nil)
    allow(gateway).to receive(:entries).and_return([entry_today, entry_other_project])
    allow(gateway).to receive(:start)
    allow(gateway).to receive(:stop)
    allow(gateway).to receive(:update_note)
    allow(gateway).to receive(:update_time)
  end
end
