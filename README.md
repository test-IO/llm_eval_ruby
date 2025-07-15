# LlmEvalRuby

A Ruby gem for LLM evaluation that provides prompt management and tracing functionality. This gem supports both local and [Langfuse](https://langfuse.com/) backends for managing prompts and traces.

## Features

- **Prompt Management**: Fetch and compile prompts from local files or Langfuse
- **Tracing**: Track LLM calls with spans, generations, and traces
- **Observable Pattern**: Automatically trace method calls with decorators
- **Multiple Adapters**: Support for local file system and Langfuse backends
- **Template Support**: Liquid templating for dynamic prompt compilation

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'llm_eval_ruby'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install llm_eval_ruby

## Configuration

Configure the gem in your application initializer:

```ruby
LlmEvalRuby.configure do |config|
  # Choose your adapter: :local or :langfuse
  config.adapter = :langfuse

  # Langfuse configuration
  config.langfuse_options = {
    public_key: "your_public_key",
    secret_key: "your_secret_key",
    host: "https://your-langfuse-instance.com"
  }

  # Local configuration (for Rails applications)
  config.local_options = {
    prompts_path: "app/prompts"
  }
end
```

## Usage

### Prompt Management

#### Text Prompts

```ruby
# Fetch a text prompt
prompt = LlmEvalRuby::PromptRepositories::Text.fetch(name: "my_prompt")

# Fetch and compile with variables
compiled_prompt = LlmEvalRuby::PromptRepositories::Text.fetch_and_compile(
  name: "my_prompt",
  variables: { user_name: "John", task: "summarize" }
)
```

#### Chat Prompts

```ruby
# Fetch chat prompts (returns array of messages)
messages = LlmEvalRuby::PromptRepositories::Chat.fetch(name: "chat_prompt")

# Fetch and compile chat prompts with variables
compiled_messages = LlmEvalRuby::PromptRepositories::Chat.fetch_and_compile(
  name: "chat_prompt",
  variables: { context: "some context", question: "What is Ruby?" }
)
```

#### Versioned Prompts

```ruby
# Fetch specific version
prompt = LlmEvalRuby::PromptRepositories::Text.fetch(
  name: "my_prompt",
  version: "v1.2.0"
)
```

### Tracing

#### Basic Tracing

```ruby
# Create a trace
# Langfuse does an upsert if id is given
trace = LlmEvalRuby::Tracer.trace(
  id: "trace_id",
  name: "llm_call",
  input: { prompt: "Hello, world!" }
)

# Create a span within a trace
span = LlmEvalRuby::Tracer.span(
  name: "preprocessing",
  trace_id: trace.id,
  input: { data: "raw input" }
)

# Create a generation (LLM call)
generation = LlmEvalRuby::Tracer.generation(
  name: "gpt_call",
  trace_id: trace.id,
  input: { messages: [{ role: "user", content: "Hello!" }] },
  model: "gpt-4"
)
```

#### Block-based Tracing

```ruby
# Trace with automatic timing
result = LlmEvalRuby::Tracer.span(
  name: "data_processing",
  input: { data: input_data }
) do |span|
  # Your processing logic here
  process_data(input_data)
end

# Generation with automatic result capture
response = LlmEvalRuby::Tracer.generation(
  name: "llm_call",
  input: { prompt: "Translate this text" },
  model: "gpt-4"
) do |generation|
  # Your LLM call here
  client.completions(prompt: "Translate this text")
end
```

### Observable Pattern

Use the `Observable` module to automatically trace method calls:

```ruby
class MyLLMService
  include LlmEvalRuby::Observable

  # Trace as a span
  observe :preprocess_data, type: :span
  def preprocess_data(input)
    # Method implementation
  end

  # Trace as a generation
  observe :call_llm, type: :generation
  def call_llm(messages)
    # LLM call implementation
  end

  # Trace as a regular trace
  observe :process_request
  def process_request(request)
    # Processing logic
  end
end

# Usage
service = MyLLMService.new
service.instance_variable_set(:@trace_id, "some-trace-id")
service.process_request(request_data)
```

### Local Prompt Management

For local prompt management, organize your prompts in the configured directory:

```
app/prompts/
├── my_chat_prompt/
│   ├── system.txt
│   └── user.txt
└── my_text_prompt/
    └── user.txt
```

Example prompt files with Liquid templating:

**app/prompts/summarize/system.txt**
```
You are a helpful assistant that summarizes text.
```

**app/prompts/summarize/user.txt**
```
Please summarize the following text for {{ user_name }}:

{{ text_to_summarize }}
```

### Advanced Usage

#### Updating Generations

```ruby
# Update a generation with results
LlmEvalRuby::Tracer.update_generation(
  id: generation.id,
  output: { response: "Generated text" },
  usage: { prompt_tokens: 10, completion_tokens: 20 }
)
```

#### Custom Trace Data

```ruby
trace = LlmEvalRuby::Tracer.trace(
  name: "complex_workflow",
  input: { query: "user query" },
  metadata: { user_id: "123", session_id: "abc" },
  tags: ["production", "important"]
)
```

## Adapters

### Langfuse Adapter

The Langfuse adapter provides:
- Cloud-based prompt management
- Advanced tracing and analytics
- Version control for prompts
- Team collaboration features

### Local Adapter

The local adapter provides:
- File-based prompt storage
- Local development workflow
- No external dependencies
- Simple prompt organization

## Error Handling

The gem includes basic error handling:

```ruby
begin
  prompt = LlmEvalRuby::PromptRepositories::Text.fetch(name: "nonexistent")
rescue LlmEvalRuby::Error => e
  puts "Error: #{e.message}"
end
```

## Requirements

- Ruby >= 3.3.0
- HTTParty for API calls
- Liquid for template rendering

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/test-IO/llm_eval_ruby. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/test-IO/llm_eval_ruby/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the LlmEvalRuby project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/test-IO/llm_eval_ruby/blob/HEAD/CODE_OF_CONDUCT.md).
