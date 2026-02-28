# frozen_string_literal: true

module QTimetrap
  # Tiny DI container that registers app services and memoized singletons.
  class Container
    def initialize(config:)
      @config = config
      @providers = {}
      @memoized = {}
      register_defaults
    end

    def register(key, &provider)
      providers[key.to_sym] = provider
    end

    def fetch(key)
      name = key.to_sym
      return memoized[name] if memoized.key?(name)

      provider = providers.fetch(name)
      memoized[name] = provider.call
    end

    private

    attr_reader :config, :providers, :memoized

    def register_defaults
      register_core
      register_ui
    end

    def register_core
      register(:theme) { Styles::Theme.new(name: config.theme_name, root: Application.root) }
      register(:settings_store) { Services::SettingsStore.new }
      register(:timetrap_gateway) { Services::TimetrapGateway.new(bin: config.timetrap_bin) }
      register(:main_view_model) { ViewModels::MainViewModel.new(gateway: fetch(:timetrap_gateway)) }
    end

    def register_ui
      register(:main_window) do
        Views::MainWindow.new(
          view_model: fetch(:main_view_model),
          theme: fetch(:theme),
          settings_store: fetch(:settings_store)
        )
      end
    end
  end
end
