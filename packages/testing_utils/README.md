# Testing utilities

This private package is test-only support for the Sunnah Everyday Flutter
workspace. It provides deterministic viewports and a controlled `MediaQuery`
wrapper without importing an application, domain data, content bundle or
backend.

Consuming applications list it only under `dev_dependencies`. Production code
must not import it.
