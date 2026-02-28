# frozen_string_literal: true

module QTimetrap
  # Bootstraps app runtime, configuration, loader, and Qt application object.
  module Application
    module_function

    def boot!
      setup_qt
      loader.setup
      load_environment!
      load_initializers!
      load_persisted_configuration!
      qt_app
    end

    def root
      @root ||= File.expand_path('..', __dir__)
    end

    def environment
      ENV.fetch('QTIMETRAP_ENV', 'development')
    end

    def configuration
      @configuration ||= Configuration.new(environment: environment)
    end

    def configure
      yield(configuration)
    end

    def container
      @container ||= Container.new(config: configuration)
    end

    def loader
      @loader ||= Zeitwerk::Loader.new.tap do |autoload|
        autoload.push_dir(File.join(root, 'app'), namespace: QTimetrap)
        autoload.enable_reloading if configuration.enable_reloading
      end
    end

    def setup_qt
      return if @qt_app

      @qt_app = QApplication.new(0, [])
    rescue StandardError
      @qt_app ||= nil
    end

    def qt_app
      @qt_app
    end

    def load_environment!
      path = File.join(root, 'config', 'environments', "#{environment}.rb")
      require path if File.exist?(path)
    end

    def load_initializers!
      Dir[File.join(root, 'config', 'initializers', '*.rb')].each do |file|
        require file
      end
    end

    def load_persisted_configuration!
      return if env_theme_name?

      persisted_theme = Services::SettingsStore.new.read_theme_name
      configuration.theme_name = persisted_theme if persisted_theme
    end

    def env_theme_name?
      ENV.fetch('QTIMETRAP_THEME', '').strip != ''
    end
  end
end
