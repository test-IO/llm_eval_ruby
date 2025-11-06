## [Unreleased]

## [0.3.0] - 2025-11-06

- Added custom Langfuse client support for Tracer and PromptRepositories
- Tracer and PromptRepositories now accept optional `client:` parameter
- Langfuse adapters converted to instance-based for client injection
- Fixed ActiveSupport dependency issues (replaced `.blank?` and `.deep_stringify_keys`)
- Made `handle_response` public in PromptAdapters::Base
- Added comprehensive test coverage (49 new tests)

## [0.1.0] - 2024-11-26

- Initial release

## [0.2.0] - 2024-11-27

- Added text and chat prompts

## [0.2.2] - 2024-12-03

- Introduced Tracer

## [0.2.4] - 2024-12-12

- [Hotfix] prompts could not compile with variables having nested hashes with keys as symbols.

## [0.2.5] - 2024-12-16

- Added metadata field to traces.

## [0.2.6] - 2025-03-07

- Fixed span for local adapter.

## [0.2.7] - 2025-03-07

- Fixed generation update and model field in traces.

## [0.2.8] - 2025-23-07

- Prompt management
