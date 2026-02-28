# QTimetrap

Desktop UI for Timetrap built with Ruby + Qt using MVVM-ish structure and Zeitwerk.

## Run

```bash
bundle install
bundle exec bin/qtimetrap
```

## Configuration

- `QTIMETRAP_ENV` - app environment (`development` by default)
- `TIMETRAP_BIN` - timetrap CLI command (`t` by default)
- `QTIMETRAP_THEME` - theme name (`light` by default)
- `QTIMETRAP_RELOAD=1` - enables Zeitwerk reloading in development

Environment-specific setup lives in `config/environments/*.rb`.
Boot-time wiring lives in `config/initializers/*.rb`.

## Styles

Theme styles are in standard `.qss` files:

- `app/styles/themes/light/application.qss`
- `app/styles/themes/light/project_sidebar.qss`
- `app/styles/themes/light/tracker_controls.qss`
- `app/styles/themes/light/entries_list.qss`
- `app/styles/themes/dark/application.qss`
- `app/styles/themes/dark/project_sidebar.qss`
- `app/styles/themes/dark/tracker_controls.qss`
- `app/styles/themes/dark/entries_list.qss`

Runtime theme switch is available from the `THEME` button in the top controls row.
Selected theme is persisted to `~/.config/qtimetrap/config.yml` (or `$XDG_CONFIG_HOME/qtimetrap/config.yml`).
