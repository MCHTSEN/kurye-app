# Testing Guide

## Purpose
- Keep test setup fast and repeatable across future projects.

## Shared Helpers
- `test/helpers/test_app.dart`: widget pump helper with localization and
  provider overrides.
- `test/helpers/test_provider_container.dart`: provider container helper.
- `test/helpers/fakes/`: reusable fake services and builders.
- `test/helpers/robots/`: screen robots for widget and smoke flows.

## Rules
- Prefer shared fake builders over per-test ad-hoc fake classes.
- Override runtime and backend providers instead of invoking platform
  plugins in tests.
- Keep one smoke `integration_test` route flow on the mock backend.
- Feature completion checklist:
  - unit test the repository/controller logic that owns decisions
  - add at least one widget test for the feature's main screen path
  - add/update a golden test when the UI contract matters visually
  - touch the smoke flow when the feature changes navigation entry or
    core app flow

## Last Updated
- 2026-03-08
