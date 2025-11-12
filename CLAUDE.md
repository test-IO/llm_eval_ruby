# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**llm_eval_ruby** is a Ruby gem that provides LLM evaluation functionality through two main features:
1. **Prompt Management**: Fetch and compile prompts using Liquid templating
2. **Tracing**: Track LLM calls with traces, spans, and generations

The gem supports two backend adapters:
- **Langfuse**: Cloud-based prompt and trace management via API
- **Local**: File-based storage for prompts and traces

## Development Commands

### Testing
```bash
bundle exec rspec                    # Run all tests
bundle exec rspec spec/path_spec.rb  # Run specific test file
```

### Linting
```bash
bundle exec rubocop                  # Run RuboCop linter
bundle exec rubocop -a               # Auto-correct offenses
```

### Build & Install
```bash
bundle exec rake build               # Build the gem
bundle exec rake install             # Install locally
bundle exec rake release             # Build, tag, and push to RubyGems
```

### Default Task
```bash
bundle exec rake                     # Runs both spec and rubocop
```

## Architecture

### Core Components

**Configuration** (`lib/llm_eval_ruby/configuration.rb`)
- Global configuration via `LlmEvalRuby.configure`
- Attributes: `adapter` (`:langfuse` or `:local`), `langfuse_options`, `local_options`

**Adapter Pattern**
The gem uses an adapter pattern to support multiple backends:
- **Prompt Adapters**: `PromptAdapters::Base` → `PromptAdapters::Langfuse` / `PromptAdapters::Local`
- **Trace Adapters**: `TraceAdapters::Base` → `TraceAdapters::Langfuse` / `TraceAdapters::Local`

### Prompt Management

**Prompt Repositories** (`lib/llm_eval_ruby/prompt_repositories/`)
- `Text`: Single text prompts
- `Chat`: Multi-message chat prompts (system, user, assistant roles)
- Methods: `fetch(name:, version:)` and `fetch_and_compile(name:, variables:, version:)`

**Prompt Types** (`lib/llm_eval_ruby/prompt_types/`)
- `Base`: Abstract base class with `role` and `content`
- `System`, `User`, `Assistant`: Role-specific prompt types
- `Compiled`: Rendered prompt with Liquid variables substituted

**Liquid Templating**
All prompts support Liquid template syntax for variable interpolation. Variables are deep stringified before rendering.

### Tracing System

**Tracer** (`lib/llm_eval_ruby/tracer.rb`)
- Class methods: `trace(...)`, `span(...)`, `generation(...)`, `update_generation(...)`
- Each method instantiates a Tracer with the configured adapter and delegates to it
- Supports block syntax for automatic timing and result capture

**Trace Hierarchy**
- **Trace**: Top-level container (e.g., a user request)
- **Span**: A step within a trace (e.g., data preprocessing)
- **Generation**: An LLM API call within a trace or span

**Observable Module** (`lib/llm_eval_ruby/observable.rb`)
Include this module in classes to automatically trace methods via the `observe` decorator:
- `observe :method_name` → wraps as trace
- `observe :method_name, type: :span` → wraps as span
- `observe :method_name, type: :generation` → wraps as generation
- Requires instance variable `@trace_id` to link traces
- Automatically deep copies and sanitizes inputs (truncates base64 images)

### Langfuse Integration

**API Client** (`lib/llm_eval_ruby/api_clients/langfuse.rb`)
- HTTParty-based client for Langfuse API
- Endpoints: `fetch_prompt`, `get_prompts`, `create_trace`, `create_span`, `create_generation`, etc.
- All trace operations use the `/ingestion` endpoint with batched events
- Traces support upsert by ID (create or update based on ID presence)

**Serializers** (`lib/serializers/`)
- `PromptSerializer`: Converts prompt objects for API
- `TraceSerializer`: Converts trace objects for API
- `GenerationSerializer`: Converts generation objects with usage metadata

### Local Adapter

**File Structure**
Prompts are stored in directories named after the prompt:
```
app/prompts/
├── my_chat_prompt/
│   ├── system.txt
│   ├── user.txt
│   └── assistant.txt  (optional)
└── my_text_prompt/
    └── user.txt
```

## Key Implementation Notes

1. **Adapter Selection**: Determined at runtime based on `LlmEvalRuby.config.adapter`
2. **Custom Client Support**: Langfuse adapters support custom client injection via `client:` parameter
   - `LlmEvalRuby::Tracer.new(adapter: :langfuse, client: custom_client)`
   - `LlmEvalRuby::PromptRepositories::Text.new(adapter: :langfuse, client: custom_client)`
   - If no client is provided, uses default from `langfuse_options` config
   - Local adapter does not use clients
3. **Prompt Versioning**: Only supported by Langfuse adapter; local adapter ignores version parameter
4. **Trace IDs**: Must be manually managed when using Observable pattern via `@trace_id`
5. **Deep Copy**: Observable module deep copies inputs to prevent mutation; handles Marshal-incompatible objects gracefully
6. **Base64 Sanitization**: Automatically truncates base64-encoded images in traced inputs to 30 characters
7. **Ruby Version**: Requires Ruby >= 3.3.0

## Dependencies

- `httparty` (~> 0.22.0): HTTP client for Langfuse API
- `liquid` (~> 5.5.0): Template rendering engine
