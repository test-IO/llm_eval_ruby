# frozen_string_literal: true

require_relative "trace_adapters/langfuse"
require_relative "trace_adapters/local"

module LlmEvalRuby
  class Tracer
    attr_reader :adapter

    def self.trace(...)
      new(adapter: LlmEvalRuby.config.adapter).trace(...)
    end

    def self.span(...)
      new(adapter: LlmEvalRuby.config.adapter).span(...)
    end

    def self.generation(...)
      new(adapter: LlmEvalRuby.config.adapter).generation(...)
    end

    def self.update_generation(...)
      new(adapter: LlmEvalRuby.config.adapter).update_generation(...)
    end

    def initialize(adapter:, client: nil)
      @adapter = case adapter
                 when :langfuse
                   TraceAdapters::Langfuse.new(client:)
                 when :local
                   TraceAdapters::Local
                 else
                   raise "Unsupported adapter #{adapter}"
                 end
    end

    def trace(...)
      adapter.trace(...)
    end

    def span(...)
      adapter.span(...)
    end

    def generation(...)
      adapter.generation(...)
    end

    def update_generation(...)
      adapter.update_generation(...)
    end
  end
end
