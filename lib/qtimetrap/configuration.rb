# frozen_string_literal: true

module QTimetrap
  # Mutable runtime configuration used during application boot.
  class Configuration
    attr_accessor :environment, :theme_name, :timetrap_bin, :enable_reloading

    def initialize(environment: 'development')
      @environment = environment
      @theme_name = 'light'
      @timetrap_bin = 't'
      @enable_reloading = environment == 'development'
    end
  end
end
