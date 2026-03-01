# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'fileutils'

# Installs QTimetrap desktop entry and icon theme assets under ~/.local/share.
module DesktopInstall
  module_function

  def root
    File.expand_path(__dir__)
  end

  def home
    Dir.home
  end

  def applications_dir
    File.join(home, '.local', 'share', 'applications')
  end

  def icons_root
    File.join(home, '.local', 'share', 'icons', 'hicolor')
  end

  def desktop_file
    File.join(applications_dir, 'qtimetrap.desktop')
  end

  def icon_svg_src
    File.join(root, 'app', 'assets', 'icons', 'qtimetrap-icon.svg')
  end

  def icon_png_sizes
    {
      '128x128' => File.join(root, 'app', 'assets', 'icons', 'qtimetrap-icon-128.png'),
      '256x256' => File.join(root, 'app', 'assets', 'icons', 'qtimetrap-icon-256.png'),
      '512x512' => File.join(root, 'app', 'assets', 'icons', 'qtimetrap-icon-512.png')
    }
  end

  def exec_path
    rbenv_shim = File.join(home, '.rbenv', 'shims', 'qtimetrap')
    ENV.fetch('QTIMETRAP_DESKTOP_EXEC', File.executable?(rbenv_shim) ? rbenv_shim : 'qtimetrap')
  end

  def install!
    FileUtils.mkdir_p(applications_dir)
    install_icons!
    File.write(desktop_file, desktop_entry)
    validate_desktop_file!
    refresh_icon_cache!
    puts "Installed desktop entry: #{desktop_file}"
  end

  def install_icons!
    FileUtils.mkdir_p(File.join(icons_root, 'scalable', 'apps'))
    FileUtils.cp(icon_svg_src, File.join(icons_root, 'scalable', 'apps', 'qtimetrap.svg'))
    icon_png_sizes.each do |size, src|
      next unless File.file?(src)

      target_dir = File.join(icons_root, size, 'apps')
      FileUtils.mkdir_p(target_dir)
      FileUtils.cp(src, File.join(target_dir, 'qtimetrap.png'))
    end
  end

  def desktop_entry
    <<~DESKTOP
      [Desktop Entry]
      Type=Application
      Version=1.0
      Name=QTimetrap
      Comment=Desktop Timetrap UI on Qt
      Exec=#{exec_path}
      Icon=qtimetrap
      Terminal=false
      Categories=Office;
      StartupNotify=true
      StartupWMClass=qtimetrap
      X-KDE-StartupNotify=true
    DESKTOP
  end

  def validate_desktop_file!
    return unless system('sh', '-lc', 'command -v desktop-file-validate >/dev/null 2>&1')
    return if system('desktop-file-validate', desktop_file)

    abort("desktop-file-validate failed for #{desktop_file}")
  end

  def refresh_icon_cache!
    return unless system('sh', '-lc', 'command -v gtk-update-icon-cache >/dev/null 2>&1')
    return unless File.file?(File.join(icons_root, 'index.theme'))

    system('gtk-update-icon-cache', '-q', '-t', icons_root)
  end
end

namespace :desktop do
  desc 'Install QTimetrap desktop entry into ~/.local/share/applications'
  task :install do
    DesktopInstall.install!
  end
end
