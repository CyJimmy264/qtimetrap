# frozen_string_literal: true

module QTimetrap
  module Entries
    # Renders expandable week/day/project nodes and leaf time entries.
    class ListComponent
      include ListHostHelpers
      include ListStateHelpers
      include ListTaskEditorHelpers
      include EntryRowRenderHelpers
      include QtUiHelpers
      include TreeHelpers
      include RenderHelpers

      HOST_HORIZONTAL_MARGINS = 28
      WIDTH_PADDING = 24
      TIME_FILTER_DEBOUNCE_MS = 220
      RENDER_SLICE_MS = 4

      attr_reader :widget

      def initialize(parent:, callbacks: {}, task_suggestions_for_project: nil)
        @parent = parent
        @on_entry_note_change = callbacks[:on_entry_note_change]
        @on_entry_task_change = callbacks[:on_entry_task_change]
        @task_suggestions_for_project = task_suggestions_for_project
        @on_entry_time_change = callbacks[:on_entry_time_change]
        @on_entry_archive = callbacks[:on_entry_archive]
        @on_time_range_change = callbacks[:on_time_range_change]
        initialize_state!
        build
      end

      def render(nodes)
        time_filter_debounce.stop if time_filter_debounce&.is_active
        render_timer.stop if render_timer.is_active
        @theme_style_queue = []
        @render_generation = render_generation.to_i + 1
        @rendering = true
        @current_nodes = Array(nodes)
        @branch_bindings = {}
        @leaf_labels = []
        @entry_rows = []
        @entry_rows_by_id = {}
        @entry_row_parent_branches = {}
        @project_branch_entry_ids = {}
        @container_branch_ids = {}
        @row_filter_state = {}
        @width_queue = []
        @visibility_queue = []
        @visible_branch_ids = nil
        @visible_branch_labels = {}
        @visible_entry_ids = nil
        @task_suggestion_cache = {}
        @render_needs_stretch = true
        rebuild_host!
        @empty_label = QLabel.new(host)
        @empty_label.object_name = 'entry_node_empty'
        @empty_label.fixed_height = 32
        @empty_label.visible = false
        host_layout.add_widget(@empty_label)
        @render_queue = []
        enqueue_render_nodes(current_nodes, level: 0, layout: host_layout, parent_widget: host)
        render_timer.start
        nil
      end

      def filter_to(nodes)
        branch_nodes = {}
        entry_ids = {}
        project_entry_ids = Hash.new { |hash, key| hash[key] = [] }
        empty_label = nil
        visit = lambda do |collection, project_branch_id = nil|
          Array(collection).each do |node|
            if node.fetch(:type) == :entry
              entry_id = node.fetch(:entry_id, node.fetch(:id))
              entry_ids[entry_id] = true
              project_entry_ids[project_branch_id] << entry_id if project_branch_id
            elsif node.fetch(:type) == :empty
              empty_label = node.fetch(:label)
            elsif branch_node?(node)
              branch_nodes[node.fetch(:id)] = node
              next_project_id = node.fetch(:type) == :project ? node.fetch(:id) : project_branch_id
              visit.call(node.fetch(:children), next_project_id)
            end
          end
        end
        visit.call(nodes)

        @visible_branch_ids = branch_nodes
        @visible_branch_labels = branch_nodes.transform_values { |node| node.fetch(:label) }
        @visible_entry_ids = entry_ids
        @visible_project_entry_ids = project_entry_ids
        @visibility_queue = branch_bindings.filter_map do |node_id, binding|
          visible = branch_nodes.key?(node_id)
          label = branch_nodes[node_id]&.fetch(:label)
          next if binding[:filter_visible] == visible && (!visible || binding[:label] == label)

          [:branch, node_id]
        end
        project_branch_entry_ids.each do |branch_id, entry_keys|
          next unless project_entry_ids.key?(branch_id)

          visible_ids = project_entry_ids.fetch(branch_id)
          entry_keys.each do |entry_id|
            visible = visible_ids.include?(entry_id)
            next if row_filter_state[entry_id] == visible

            @visibility_queue << [:entry, entry_id, entry_rows_by_id.fetch(entry_id), visible]
          end
        end
        @visibility_queue << [:empty, empty_label]
        if visibility_queue.any?
          @rendering = true
          render_timer.start
        end
        nil
      end

      def update_time_range_inputs(from_at:, to_at:)
        @syncing_time_filters = true
        set_time_filter_state(
          toggle: time_filter_from_toggle,
          input: time_filter_from_input,
          value: from_at
        )
        set_time_filter_state(
          toggle: time_filter_to_toggle,
          input: time_filter_to_input,
          value: to_at
        )
      ensure
        @syncing_time_filters = false
      end

      def apply_theme_stylesheet(stylesheet, external_targets: [], defer: false)
        @entry_stylesheet = stylesheet
        @entry_scroll_stylesheet = stylesheet_for_ids(stylesheet, %w[entries_scroll])
        @entry_toolbar_stylesheet = stylesheet_for_ids(stylesheet, %w[
          entries_toolbar entries_expand_all entries_collapse_all
          entries_time_filter_from_toggle entries_time_filter_to_toggle
          entries_time_filter_from entries_time_filter_to
        ])
        @entry_host_stylesheet = stylesheet_for_ids(stylesheet, %w[entries_host])
        @entry_row_stylesheet = stylesheet_for_ids(stylesheet, ENTRY_ROW_STYLE_IDS)
        @entry_empty_stylesheet = stylesheet_for_ids(stylesheet, %w[entry_node_empty])
        @entry_branch_stylesheets = %w[week day project].to_h do |type|
          name = "entry_node_#{type}"
          [name, stylesheet_for_ids(stylesheet, [name])]
        end
        @theme_style_queue = theme_style_targets(stylesheet).concat(external_targets)
        @rendering = true if defer && theme_style_queue.any?
        unless defer
          scroll_area.style_sheet = @entry_scroll_stylesheet
          toolbar.style_sheet = @entry_toolbar_stylesheet
          @theme_style_queue.clear
        end
        render_timer.start if theme_style_queue.any?
        nil
      end

      def shutdown
        render_timer.stop if render_timer&.is_active
        return unless time_filter_debounce

        time_filter_debounce.stop if time_filter_debounce.is_active
      end

      private

      attr_reader :parent, :host, :host_layout, :expanded, :current_nodes, :branch_bindings, :leaf_labels, :entry_rows,
                  :rendering, :scroll_area, :on_entry_note_change, :on_entry_task_change, :task_suggestions_for_project,
                  :on_entry_time_change, :on_entry_archive, :on_time_range_change,
                  :time_filter_from_toggle, :time_filter_to_toggle, :time_filter_from_input, :time_filter_to_input,
                  :time_filter_debounce, :render_timer, :render_queue, :render_generation, :width_queue,
                  :task_suggestion_cache, :visibility_queue, :entry_rows_by_id, :visible_branch_ids,
                  :visible_branch_labels, :visible_entry_ids, :empty_label, :project_branch_entry_ids,
                  :container_branch_ids, :entry_row_parent_branches, :row_filter_state, :theme_style_queue, :toolbar

      def build
        @widget = QWidget.new(parent)
        widget.object_name = 'entries_panel'
        panel_layout = build_panel_layout
        @time_filter_debounce = build_time_filter_debounce_timer
        @toolbar = build_toolbar(parent_widget: widget)
        panel_layout.add_widget(toolbar)
        @scroll_area = build_scroll_area
        bind_scroll_resize
        panel_layout.add_widget(scroll_area)
        panel_layout.set_stretch(1, 1)
        rebuild_host!
        @render_timer = QTimer.new(widget)
        render_timer.interval = 1
        render_timer.connect('timeout') { |_| process_render_slice(render_generation) }
      end

      def enqueue_render_nodes(nodes, level:, layout:, parent_widget:)
        nodes.reverse_each do |node|
          render_queue << [node, level, layout, parent_widget]
        end
      end

      def process_render_slice(generation)
        return unless generation == render_generation

        deadline = Process.clock_gettime(Process::CLOCK_MONOTONIC) + (RENDER_SLICE_MS / 1000.0)
        content_changed = false
        while queues_pending? && Process.clock_gettime(Process::CLOCK_MONOTONIC) < deadline
          if theme_style_queue.any?
            target, stylesheet = theme_style_queue.shift
            target.style_sheet = stylesheet
          elsif visibility_queue.any?
            content_changed = true
            apply_filter_work(visibility_queue.pop)
          elsif width_queue.any?
            content_changed = true
            width_queue.pop.fixed_width = branch_button_width
          else
            content_changed = true
            work = render_queue.pop
            if work.first == :entry_stage
              process_entry_row_stage(work[2], work[1], work[3])
            elsif work.first == :branch_complete
              show_rendered_branch_children(work[1])
            else
              node, level, layout, parent_widget = work
              render_one_node(node, level, layout: layout, parent_widget: parent_widget)
            end
          end
        end

        if render_queue.empty? && @render_needs_stretch
          content_changed = true
          host_layout.add_stretch(1)
          @render_needs_stretch = false
        end

        if !queues_pending?
          @rendering = false
          host.update if content_changed
          render_timer.stop if render_timer.is_active
        end
      end

      def queues_pending?
        render_queue.any? || width_queue.any? || visibility_queue.any? || theme_style_queue.any?
      end

      def theme_style_targets(stylesheet)
        targets = [[toolbar, @entry_toolbar_stylesheet]]
        unless rendering
          branch_bindings.each do |_node_id, binding|
            targets << [binding.fetch(:button), @entry_branch_stylesheets.fetch("entry_node_#{binding.fetch(:type)}")]
          end
          entry_rows.each do |row|
            targets << [row, @entry_row_stylesheet]
          end
          targets << [empty_label, @entry_empty_stylesheet] if empty_label
        end
        targets.reject { |target, rules| target.nil? || rules.empty? }
      end

      ENTRY_ROW_STYLE_IDS = %w[
        entry_node_entry_row entry_node_entry_prefix entry_node_entry_time_sep
        entry_node_entry_start entry_node_entry_end entry_node_entry_note
        entry_node_entry_task entry_node_entry_task_editor entry_node_entry_archive
      ].freeze

      def stylesheet_for_ids(stylesheet, ids)
        id_pattern = ids.map { |id| Regexp.escape("##{id}") }.join('|')
        stylesheet.scan(/([^{}]+)\{([^{}]*)\}/m).filter_map do |selectors, declarations|
          selected = selectors.split(',').map(&:strip).select do |selector|
            selector.match?(/(?:#{id_pattern})(?:\b|(?=[:\s.#>+~\[]))/)
          end
          next if selected.empty?

          "#{selected.join(",\n")} {#{declarations}}"
        end.join("\n")
      end

      def apply_entry_widget_styles(target, ids)
        stylesheet = case ids
                     when %w[entries_host] then @entry_host_stylesheet
                     when ListComponent::ENTRY_ROW_STYLE_IDS then @entry_row_stylesheet
                     when %w[entry_node_empty] then @entry_empty_stylesheet
                     else @entry_branch_stylesheets&.fetch(ids.first, nil)
                     end
        target.style_sheet = stylesheet if stylesheet && !stylesheet.empty?
      end

      def apply_filter_work(work)
        case work.first
        when :branch then apply_branch_filter(work[1])
        when :entry
          work[2].visible = work[3]
          row_filter_state[work[1]] = work[3]
        when :empty
          empty_label.text = work[1] || 'No entries for filter'
          empty_label.visible = visible_entry_ids.empty?
        end
      end

      def apply_branch_filter(node_id)
        binding = branch_bindings.fetch(node_id)
        visible = visible_branch_ids.key?(node_id)
        expanded_state = expanded.fetch(node_id, true)
        binding.fetch(:button).visible = visible
        binding.fetch(:children_container).visible = visible && expanded_state
        label = visible_branch_labels[node_id] || binding.fetch(:label)
        binding[:label] = label
        binding[:filter_visible] = visible
        binding.fetch(:button).text = branch_button_text(binding.fetch(:level), label, expanded_state)
      end

      def render_one_node(node, level, layout:, parent_widget:)
        if node.fetch(:type) == :empty
          apply_entry_widget_styles(empty_label, %w[entry_node_empty])
          return render_empty_node(node)
        end
        return start_entry_row_render(node, level, layout: layout, parent_widget: parent_widget) if node.fetch(:type) == :entry
        return render_node(node, level, layout: layout, parent_widget: parent_widget) unless branch_node?(node)

        node_id = node.fetch(:id)
        label = node.fetch(:label)
        expanded_state = expanded.fetch(node_id, true)
        button = build_branch_button(node, level, expanded_state, parent_widget: parent_widget)
        apply_entry_widget_styles(button, [object_name_for(node)])
        layout.add_widget(button)
        children_container, children_layout = build_children_container(parent_widget)
        layout.add_widget(children_container)
        register_branch_binding(
          node_id: node_id,
          button: button,
          children_container: children_container,
          label: label,
          level: level
        )
        branch_bindings[node_id][:type] = node.fetch(:type)
        if node.fetch(:type) == :project
          container_branch_ids[children_container.handle.address] = node_id
          project_branch_entry_ids[node_id] = []
        end
        children_container.visible = false
        button.text = branch_button_text(level, label, expanded_state)
        button_visible = visible_branch_ids.nil? || visible_branch_ids.key?(node_id)
        button.visible = button_visible
        branch_bindings[node_id][:filter_visible] = button_visible
        if expanded_state
          render_queue << [:branch_complete, node_id]
          enqueue_render_nodes(node.fetch(:children), level: level + 1, layout: children_layout,
                               parent_widget: children_container)
        end
      end

      def show_rendered_branch_children(node_id)
        binding = branch_bindings.fetch(node_id)
        visible = visible_branch_ids.nil? || visible_branch_ids.key?(node_id)
        expanded_state = expanded.fetch(node_id, true)
        binding.fetch(:button).visible = visible
        binding.fetch(:children_container).visible = visible && expanded_state
        label = visible_branch_labels[node_id] || binding.fetch(:label)
        binding[:label] = label
        binding[:filter_visible] = visible
        binding.fetch(:button).text = branch_button_text(binding.fetch(:level), label, expanded_state)
      end

      def render_empty_node(node)
        empty_label.text = node.fetch(:label)
        empty_label.visible = true
      end

      def branch_button_width
        available = scroll_area.width - HOST_HORIZONTAL_MARGINS - WIDTH_PADDING
        [available, 120].max
      end

      def adjust_node_widths
        @width_queue = [
          *branch_bindings.values.map { |binding| binding.fetch(:button) },
          *leaf_labels,
          *entry_rows
        ]
        render_timer.start if width_queue.any? && !render_timer.is_active
      end

      def build_panel_layout
        QVBoxLayout.new(widget).tap do |layout|
          layout.set_contents_margins(0, 0, 0, 0)
          layout.spacing = 6
        end
      end

      def build_scroll_area
        QScrollArea.new(widget).tap do |area|
          area.object_name = 'entries_scroll'
          area.widget_resizable = true
        end
      end

      def bind_scroll_resize
        scroll_area.on(:resize) { |_| adjust_node_widths }
      end
    end
  end
end
