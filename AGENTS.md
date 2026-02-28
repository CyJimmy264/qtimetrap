# Repository Guidelines

## Project Structure & Module Organization
`QTimetrap` is a Ruby gem with a Rails-like layout and Qt UI.
- `app/models`, `app/services`, `app/view_models`, `app/views`, `app/components`: app logic (MVVM + UI composition).
- `app/styles/themes/<theme>/*.qss`: theme styles (`light`, `dark`).
- `config/application.rb`: bootstrapping (`Zeitwerk`, environment, initializers, persisted settings).
- `config/environments/*.rb`, `config/initializers/*.rb`: runtime configuration.
- `lib/qtimetrap/*.rb`: gem entrypoint, container, configuration.
- `spec/**`: RSpec tests (`models`, `services`, `view_models`, `views`, `styles`, `support`).

## Build, Test, and Development Commands
- `bin/qtimetrap`: run the desktop app.
- `rspec`: run full test suite.
- `rspec spec/views/main_window_spec.rb`: run GUI-facing integration specs only.
- `ruby -c path/to/file.rb`: quick syntax check for a file.
- `gem build qtimetrap.gemspec`: build the gem artifact.

If `bundle install` fails due to local `qt` gem resolution, use the current shell where `qt` is already installed via rbenv.

## Coding Style & Naming Conventions
- Ruby style: 2-space indentation, `# frozen_string_literal: true`, small focused classes.
- Use `snake_case` for methods/files, `CamelCase` for classes/modules.
- Keep domain logic in `services`/`view_models`; keep `views/components` thin.
- Prefer `Zeitwerk`-friendly naming (`app/services/settings_store.rb` => `QTimetrap::Services::SettingsStore`).
- Store UI styles in `.qss` files, not inline Ruby strings.

## Testing Guidelines
- Framework: `RSpec`.
- Add specs for every behavior change; include both happy-path and failure-path cases.
- Naming: `spec/<layer>/<class_or_feature>_spec.rb`.
- For UI changes, update `spec/views/main_window_spec.rb` and verify theme/interaction behavior.

## Commit & Pull Request Guidelines
This repository currently has no commit history; use this convention going forward:
- Commit message format: imperative, concise subject (e.g., `Add runtime theme persistence`).
- Keep commits focused (one logical change per commit).
- PRs should include:
  - what changed and why,
  - test evidence (`rspec` output),
  - screenshots/GIFs for UI changes,
  - any config/env changes (`QTIMETRAP_THEME`, `TIMETRAP_BIN`, etc.).

## Configuration & Runtime Notes
- Theme persistence uses: `~/.config/qtimetrap/config.yml` (or `$XDG_CONFIG_HOME/qtimetrap/config.yml`).
- Env overrides: `QTIMETRAP_ENV`, `QTIMETRAP_THEME`, `QTIMETRAP_RELOAD`, `TIMETRAP_BIN`.

## Qt Bridge Policy
- Do not introduce application-level workarounds for missing Qt Bridge capabilities if the feature is required by design.
- If a required Qt API is missing in the bridge (for example `QObject#setObjectName`, `setProperty`, typed `QVariant` transport), first request/add bridge support, then implement the app feature using that API.
- Temporary fallback code is acceptable only for short-lived local debugging and should not be merged as the final solution.

## Qt API Contract
- Application code must use Ruby-style Qt bridge methods (`snake_case`) as a hard contract.
- Do not add defensive `respond_to?` guards around required Qt API calls in `app/**`.
- Fail fast on missing methods; bridge/API regressions should surface immediately.
- Test doubles/mocks must explicitly stub required Qt methods (instead of relying on runtime capability checks).
