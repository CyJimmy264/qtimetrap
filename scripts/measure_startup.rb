# frozen_string_literal: true

# Measures a cold QTimetrap launch through its first complete render.
# Run with:
# mkdir -p /tmp/qtimetrap-startup-profile
# env XDG_CONFIG_HOME=/tmp/qtimetrap-startup-profile QT_QPA_PLATFORM=xcb xvfb-run -a ruby scripts/measure_startup.rb

started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)
$stdout.sync = true
def elapsed_ms(started_at)
  ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - started_at) * 1000).round(1)
end

root = File.expand_path('..', __dir__)
$LOAD_PATH.unshift(File.join(root, 'lib'))

require 'qtimetrap'
puts format('require qtimetrap: %.1f ms', elapsed_ms(started_at))

boot_started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)
app = QTimetrap::Application.boot!
puts format('Application.boot!: %.1f ms', elapsed_ms(boot_started_at))

# Resolve the autoloads before prepending probes, so the measured application
# path itself remains unchanged.
QTimetrap::Views::MainWindow
QTimetrap::ViewModels::MainViewModel
QTimetrap::Services::TimetrapGateway

module StartupMeasurement
  def initialize(...)
    started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    super
  ensure
    puts format('MainWindow.initialize: %.1f ms', elapsed_ms(started_at))
  end

  private

  def build_window(...)
    started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    super
  ensure
    puts format('MainWindow.build_window: %.1f ms', elapsed_ms(started_at))
  end

  def on_tick(...)
    unless @startup_measurement_first_tick
      @startup_measurement_first_tick = true
      puts format('time from show() to first tick: %.1f ms', elapsed_ms($startup_measurement_shown_at))
    end
    super
  end
end

module ViewModelMeasurement
  def refresh!(...)
    started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    super
  ensure
    puts format('MainViewModel.refresh!: %.1f ms', elapsed_ms(started_at))
    puts format('entries loaded: %d', entries.size) if entries
  end
end

module GatewayMeasurement
  def active_started_at(...)
    started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    super
  ensure
    puts format('TimetrapGateway.active_started_at: %.1f ms', elapsed_ms(started_at))
  end

  def entries(...)
    started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    super
  ensure
    puts format('TimetrapGateway.entries: %.1f ms', elapsed_ms(started_at))
  end
end

module FirstRenderMeasurement
  def render!(...)
    render_started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    super
    return if @startup_measurement_rendered

    @startup_measurement_rendered = true
    puts format('initial render! duration: %.1f ms', elapsed_ms(render_started_at))
    puts format('time to first complete render: %.1f ms', elapsed_ms($startup_measurement_started_at))
    QApplication.quit
  end

  def render_sidebar(...)
    started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    super
  ensure
    puts format('render_sidebar: %.1f ms', elapsed_ms(started_at))
  end

  def render_controls(...)
    started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    super
  ensure
    puts format('render_controls: %.1f ms', elapsed_ms(started_at))
  end

  def render_entries_panel(...)
    started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    super
  ensure
    puts format('render_entries_panel: %.1f ms', elapsed_ms(started_at))
  end
end

QTimetrap::Views::MainWindow.prepend(StartupMeasurement)
QTimetrap::ViewModels::MainViewModel.prepend(ViewModelMeasurement)
QTimetrap::Services::TimetrapGateway.prepend(GatewayMeasurement)
QTimetrap::Views::MainWindowRuntimeRenderHelpers.prepend(FirstRenderMeasurement)

$startup_measurement_started_at = started_at
window_started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)
main_window = QTimetrap::Application.container.fetch(:main_window)
puts format('container.fetch(:main_window): %.1f ms', elapsed_ms(window_started_at))

module EntriesListMeasurement
  def render(nodes)
    started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    super
  ensure
    puts format('Entries::ListComponent.render: %.1f ms', elapsed_ms(started_at))
  end
end

QTimetrap::Entries::ListComponent.prepend(EntriesListMeasurement)

main_window.show
$startup_measurement_shown_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)
puts format('time to show(): %.1f ms', elapsed_ms(started_at))
begin
  app.exec
ensure
  app.dispose
end
