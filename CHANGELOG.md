# Changelog

All notable changes to this project will be documented in this file.

## [0.1.2] - 2026-03-17

### Added
- Editable task reassignment for individual entries.
- Archive mode with archive/restore flow for entry rows.
- Multi-select project filtering in the sidebar with recent-activity ordering for projects and tasks.
- Date/time range filtering for rendered entry nodes.
- Custom RuboCop enforcement for Ruby-style Qt setter usage in `app/**`.

### Changed
- Switched project license to BSD-2-Clause.
- Moved specs under `spec/qtimetrap/**` and removed the RuboCop todo file.
- Improved README, packaging metadata, and release preparation.
- Tracker inputs now take focus on direct click when editing is allowed.

### Fixed
- Preserved running tracker inputs when selecting sidebar tasks.
- Closed inline editors on outside click without relying on application-level hit-testing workarounds.
- Restored entry task editor styling and display-field behavior.
- Reduced UI regressions around inline task editing, scrolling, and blur handling.

## [0.1.1] - 2026-03-14

### Added
- Fedora/COPR packaging, desktop entry installation, and application icons.
- Sidebar task filtering, multi-project filtering, and archive support groundwork.
- Editable note and time updates for entry leaves.

### Changed
- Updated runtime dependency to newer `qt` releases in the 0.1 series.

## [0.1.0] - 2026-03-05

### Added
- Initial release of QTimetrap as a Ruby gem with a Qt desktop UI.
- MVVM application structure with Zeitwerk autoloading, themed QSS styling, and Timetrap integration.
