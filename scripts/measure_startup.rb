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

def cpu_elapsed_ms(started_at)
  ((Process.clock_gettime(Process::CLOCK_THREAD_CPUTIME_ID) - started_at) * 1000).round(1)
end

def run_next_profile_action
  action = $startup_actions_remaining.shift
  unless action
    QApplication.quit
    return
  end

  view_model = $startup_main_window.instance_variable_get(:@view_model)
  $startup_current_action = action
  started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)

  case action
  when :project_selection
    project = view_model.project_names.find { |name| name != '* ALL' }
    $startup_main_window.send(:handle_project_selected, [project], project) if project
  when :task_selection
    task = view_model.task_names_for_selected_project.first
    $startup_main_window.send(:handle_task_selected, [task], task) if task
  when :time_range_reset
    $startup_main_window.send(:handle_time_range_changed, nil, nil)
  when :archive_mode
    $startup_main_window.send(:handle_archive_mode_toggled, true)
  when :theme_switch
    $startup_main_window.send(:switch_theme!)
  end

  puts format('%s handler: %.1f ms', action, elapsed_ms(started_at))
  unless $startup_main_window.instance_variable_get(:@entries).send(:rendering)
    $startup_current_action = nil
    run_next_profile_action
  end
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
    $startup_measurement_render_started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    super
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
$startup_measurement_render_slices = []
$startup_measurement_render_cpu_slices = []
$startup_measurement_node_timings = []
$startup_measurement_stage_timings = []
$startup_measurement_combo_timings = []
$startup_measurement_suggestion_timings = []
$startup_measurement_row_build_timings = []
$startup_measurement_constructor_timings = []
$startup_measurement_scroll_timings = []
$startup_actions_remaining = ENV.fetch(
  'QTIMETRAP_PROFILE_ACTIONS',
  'project_selection,task_selection,time_range_reset,archive_mode,theme_switch'
).split(',').map(&:to_sym)
window_started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)
main_window = QTimetrap::Application.container.fetch(:main_window)
$startup_main_window = main_window
puts format('container.fetch(:main_window): %.1f ms', elapsed_ms(window_started_at))

module EntriesListMeasurement
  def apply_theme_stylesheet(...)
    $startup_measurement_render_started_at ||= Process.clock_gettime(Process::CLOCK_MONOTONIC) if $startup_current_action
    super
  end

  def render(nodes)
    $startup_measurement_render_started_at ||= Process.clock_gettime(Process::CLOCK_MONOTONIC) if $startup_current_action
    started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    super
  ensure
    puts format('Entries::ListComponent.render enqueue: %.1f ms', elapsed_ms(started_at))
  end

  def filter_to(nodes)
    $startup_measurement_render_started_at ||= Process.clock_gettime(Process::CLOCK_MONOTONIC) if $startup_current_action
    started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    super
    puts format('filter work queued: %d, timer active: %s', send(:visibility_queue).size,
                send(:render_timer).is_active) if $startup_current_action
  ensure
    puts format('Entries::ListComponent.filter enqueue: %.1f ms', elapsed_ms(started_at))
  end

  def process_render_slice(generation)
    slice_started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    slice_cpu_started_at = Process.clock_gettime(Process::CLOCK_THREAD_CPUTIME_ID)
    super
    $startup_measurement_render_slices << elapsed_ms(slice_started_at)
    $startup_measurement_render_cpu_slices << cpu_elapsed_ms(slice_cpu_started_at)
    completed_render_started_at = $startup_measurement_render_started_at
    if $startup_current_action && ($startup_measurement_render_slices.size % 10).zero?
      puts format('filter work remaining: %d', send(:visibility_queue).size)
    end
    return unless $startup_measurement_render_started_at && !rendering

    $startup_measurement_render_started_at = nil
    puts format('render slices: %d, max slice: %.1f ms', $startup_measurement_render_slices.size,
                $startup_measurement_render_slices.max || 0)
    puts format('max slice CPU time: %.1f ms', $startup_measurement_render_cpu_slices.max || 0)
    node_timing = $startup_measurement_node_timings.max_by(&:first)
    puts format('slowest node: %.1f ms (%s)', node_timing.first, node_timing.last) if node_timing
    row_timing = $startup_measurement_row_build_timings.max_by(&:first)
    puts format('slowest entry row step: %.1f ms (%s)', row_timing.first, row_timing.last) if row_timing
    constructor_timing = $startup_measurement_constructor_timings.max_by(&:first)
    puts format('slowest Qt constructor: %.1f ms (%s)', constructor_timing.first, constructor_timing.last) if constructor_timing
    scroll_timing = $startup_measurement_scroll_timings.max_by(&:first)
    puts format('slowest scroll-area update: %.1f ms (%s)', scroll_timing.first, scroll_timing.last) if scroll_timing
    stage_timing = $startup_measurement_stage_timings.max_by(&:first)
    if stage_timing
      puts format('slowest row stage: %.1f ms wall / %.1f ms CPU (%s, task chars=%d, option index=%s, options=%s)',
                  stage_timing.first, stage_timing[4], stage_timing[1], stage_timing[2], stage_timing[3],
                  stage_timing[5])
    end
    combo_timing = $startup_measurement_combo_timings.max_by(&:first)
    puts format('slowest combo shell: %.1f ms', combo_timing.first) if combo_timing
    suggestion_timing = $startup_measurement_suggestion_timings.max_by(&:first)
    puts format('slowest suggestion lookup: %.1f ms', suggestion_timing.first) if suggestion_timing
    if $startup_current_action
      puts format('%s render settled %.1f ms after scheduling', $startup_current_action,
                  elapsed_ms(completed_render_started_at))
      $startup_current_action = nil
      $startup_measurement_render_started_at = nil
      run_next_profile_action
    elsif $startup_actions_remaining
      puts format('initial render completion: %.1f ms', elapsed_ms($startup_measurement_started_at))
      run_next_profile_action
    else
      QApplication.quit
    end
  end

  def render_one_node(node, ...)
    started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    super
  ensure
    $startup_measurement_node_timings << [elapsed_ms(started_at), node.fetch(:type)]
  end

  def process_entry_row_stage(context, stage, index)
    started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    cpu_started_at = Process.clock_gettime(Process::CLOCK_THREAD_CPUTIME_ID)
    super
  ensure
    $startup_measurement_stage_timings << [
      elapsed_ms(started_at), stage, context.fetch(:task_name, '').length, index,
      cpu_elapsed_ms(cpu_started_at),
      context.fetch(:task_options, []).length
    ]
  end

  def build_entry_task_editor_shell(...)
    started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    super
  ensure
    $startup_measurement_combo_timings << [elapsed_ms(started_at)]
  end

  def task_options_for(...)
    started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    super
  ensure
    $startup_measurement_suggestion_timings << [elapsed_ms(started_at)]
  end

  def build_entry_row(...)
    started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    super
  ensure
    $startup_measurement_row_build_timings << [elapsed_ms(started_at), :build_entry_row]
  end

  def build_entry_row_layout(...)
    started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    super
  ensure
    $startup_measurement_row_build_timings << [elapsed_ms(started_at), :build_entry_row_layout]
  end
end

QTimetrap::Entries::ListComponent.prepend(EntriesListMeasurement)

module ScrollAreaMutationMeasurement
  def take_widget(...)
    started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    super
  ensure
    $startup_measurement_scroll_timings << [elapsed_ms(started_at), :take_widget]
  end

  def widget=(value)
    started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    super
  ensure
    $startup_measurement_scroll_timings << [elapsed_ms(started_at), :set_widget]
  end
end

QScrollArea.prepend(ScrollAreaMutationMeasurement)

module DeferredDeleteMeasurement
  def delete_later(...)
    started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    super
  ensure
    $startup_measurement_scroll_timings << [elapsed_ms(started_at), :delete_later]
  end
end

QWidget.prepend(DeferredDeleteMeasurement)

module StyleSheetMeasurement
  def style_sheet=(value)
    started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    super
  ensure
    duration = elapsed_ms(started_at)
    puts format('slow style update: %.1f ms (%s, %s)', duration, self.class, object_name) if duration >= 10
  end
end

QWidget.prepend(StyleSheetMeasurement)

module QtConstructorMeasurement
  def new(...)
    started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    super
  ensure
    $startup_measurement_constructor_timings << [elapsed_ms(started_at), name]
  end
end

[QWidget, QHBoxLayout, QVBoxLayout, QLabel, QLineEdit, QPushButton, QComboBox].each do |qt_class|
  qt_class.singleton_class.prepend(QtConstructorMeasurement)
end

main_window.show
$startup_measurement_shown_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)
puts format('time to show(): %.1f ms', elapsed_ms(started_at))
begin
  app.exec
ensure
  app.dispose
end
