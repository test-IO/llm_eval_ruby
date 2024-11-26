# frozen_string_literal: true

require_relative "prompt_adapters/langfuse"
require_relative "prompt_adapters/local"

module LlmEvalRuby
  class PromptRepository
    attr_reader :adapter
  
    def initialize(adapter: :langfuse)  
      case adapter
      when :langfuse
        @adapter = PromptAdapters::Langfuse
      when :local
        @adapter = PromptAdapters::Local
      else
        raise "Unsupported adapter #{adapter}"
      end
    end
  
    def fetch(name:, version: nil)
      adapter.fetch_prompt(name:, version:)
    end
  
    def compile(name:, variables:, version: nil)
      adapter.compile(name:, version:, variables:)
    end
  end
end
