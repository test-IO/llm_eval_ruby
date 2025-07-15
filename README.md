# LlmEvalRuby

A Ruby gem that provides LLM evaluation functionality with prompt management and tracing capabilities. It supports multiple adapters for both local development and production environments with Langfuse integration.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'llm_eval_ruby', git: 'https://github.com/test-IO/llm_eval_ruby'
```

And then execute:

    $ bundle install

## Configuration

Create an initializer file (e.g., `config/initializers/llm_eval_ruby.rb`):

```ruby
LlmEvalRuby.configure do |config|
  # Choose adapter: :langfuse or :local
  config.adapter = :langfuse
  
  # Langfuse configuration (for production)
  config.langfuse_options = {
    host: ENV['LANGFUSE_HOST'],
    username: ENV['LANGFUSE_USERNAME'],
    password: ENV['LANGFUSE_PASSWORD']
  }
  
  # Local configuration (for development)
  config.local_options = {
    prompts_path: Rails.root.join('lib', 'prompts'),
    traces_path: Rails.root.join('log', 'trace.log')
  }
end
```

## Usage

### 1. Basic Tracing

```ruby
# Create a trace for a job or operation
trace = LlmEvalRuby::Tracer.trace(
  name: 'test_case_generation',
  session_id: 'session_123',
  input: { url: 'https://example.com' },
  user_id: 'test-generator',
  metadata: { workflow_id: 'wf_123' }
)

# Create spans within a trace
LlmEvalRuby::Tracer.span(name: :fetch_prompts, trace_id: trace.id) do
  # Your code here
end

# Track AI generations
generation = LlmEvalRuby::Tracer.generation(
  name: 'generate_test_cases',
  input: 'Generate test cases for login functionality',
  trace_id: trace.id
)

# ... make AI API call ...

generation.end(output: ai_response, usage: { tokens: 150 })
```

### 2. Observable Pattern for Services

```ruby
class OpenaiService
  include LlmEvalRuby::Observable
  
  attr_reader :trace_id
  
  # Automatically create spans for these methods
  observe :create_assistant, type: :span
  observe :create_file, type: :span
  observe :add_message, type: :span
  
  # Automatically track generation for this method
  observe :chat, type: :generation
  
  def initialize(session_id, trace_id = nil)
    @session_id = session_id
    @trace_id = trace_id
  end
  
  def create_assistant(params)
    # Method implementation
    # Automatically wrapped in a span
  end
  
  def chat(params)
    # Method implementation
    # Automatically tracked as a generation
  end
end
```

### 3. Prompt Management

#### Chat Prompts (System + User)
```ruby
# Fetch chat prompts (returns [system_prompt, user_prompt])
system_prompt, user_prompt = LlmEvalRuby::PromptRepositories::Chat.fetch(
  name: :validate_test_case
)

# Compile prompts with variables
compiled_prompt = user_prompt.compile(
  variables: {
    test_case_content: "Login with valid credentials",
    out_of_scope: "Performance testing"
  }
)

# Use in AI call
response = openai.chat(
  parameters: {
    model: 'gpt-4',
    messages: [
      { role: 'system', content: system_prompt.content },
      { role: 'user', content: compiled_prompt.content }
    ]
  }
)
```

#### Text Prompts (Single prompt)
```ruby
# Fetch and compile in one step
prompt = LlmEvalRuby::PromptRepositories::Text.fetch_and_compile(
  name: :precook_out_of_scope,
  variables: {
    feature_description: "User authentication",
    out_of_scope: "Load testing, Security scanning"
  }
)

# Use the compiled content
response = openai.chat(
  parameters: {
    model: 'gpt-4',
    messages: [{ role: 'user', content: prompt.content }]
  }
)
```

### 4. Real-World Example: Background Job

```ruby
class ValidateTestCaseJob < ApplicationJob
  def perform(test_case_id)
    @test_case = TestCase.find(test_case_id)
    
    # Start trace
    @trace_id = LlmEvalRuby::Tracer.trace(
      name: 'validate_test_case',
      session_id: @test_case.session_id,
      input: { test_case_id: test_case_id },
      user_id: 'validator'
    ).id
    
    # Fetch prompts with span tracking
    LlmEvalRuby::Tracer.span(name: :fetch_prompts, trace_id: @trace_id) do
      @system_prompt, @user_prompt = LlmEvalRuby::PromptRepositories::Chat.fetch(
        name: :validate_test_case
      )
    end
    
    # Compile prompt with variables
    compiled_prompt = @user_prompt.compile(
      variables: {
        test_case_content: @test_case.content,
        requirements: @test_case.requirements
      }
    )
    
    # Track AI generation
    generation = LlmEvalRuby::Tracer.generation(
      name: 'validate_test_case',
      input: compiled_prompt.content,
      trace_id: @trace_id
    )
    
    # Make AI call
    response = openai_service.chat(
      parameters: {
        model: 'gpt-4',
        messages: [
          { role: 'system', content: @system_prompt.content },
          { role: 'user', content: compiled_prompt.content }
        ]
      }
    )
    
    # End generation tracking
    generation.end(
      output: response.dig('choices', 0, 'message', 'content'),
      usage: response['usage']
    )
    
    # Process response...
  end
  
  private
  
  def openai_service
    @openai_service ||= OpenaiService.new(@test_case.session_id, @trace_id)
  end
end
```

### 5. Prompt File Structure

For local adapter, organize prompts in your `lib/prompts` directory:

```
lib/prompts/
├── chat/
│   ├── validate_test_case/
│   │   ├── system.liquid
│   │   └── user.liquid
│   └── generate_test_cases/
│       ├── system.liquid
│       └── user.liquid
└── text/
    └── precook_out_of_scope.liquid
```

Example prompt file (`lib/prompts/chat/validate_test_case/user.liquid`):
```liquid
Please validate the following test case:

Test Case Content:
{{ test_case_content }}

Out of Scope Items:
{{ out_of_scope }}

Determine if this test case is valid and in scope.
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/llm_eval_ruby. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/llm_eval_ruby/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the LlmEvalRuby project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/llm_eval_ruby/blob/master/CODE_OF_CONDUCT.md).
