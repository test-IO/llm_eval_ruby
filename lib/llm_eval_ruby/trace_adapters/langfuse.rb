# frozen_string_literal: true

require_relative "base"
require_relative "../api_clients/langfuse"
require_relative "../trace_types"

module LlmEvalRuby
  module TraceAdapters
    class Langfuse < Base
      class << self
        def trace(**kwargs)
          trace = TraceTypes::Trace.new(id: SecureRandom.uuid, **kwargs)
          response = client.create_trace(trace.to_h)

          logger.warn "Failed to create generation" if response["successes"].blank?

          trace
        end

        def update_trace(**kwargs)
          trace = TraceTypes::Trace.new(**kwargs)
          response = client.update_trace(trace.to_h)

          logger.warn "Failed to update trace" if response["successes"].blank?

          trace
        end

        def span(**kwargs)
          span = TraceTypes::Span.new(id: SecureRandom.uuid, **kwargs)
          response = client.create_span(span.to_h)

          logger.warn "Failed to create span" if response["successes"].blank?

          return span unless block_given?

          result = yield span

          end_span(span, result)

          result
        end

        def update_generation(**kwargs)
          generation = TraceTypes::Generation.new(**kwargs)
          response = client.update_generation(generation.to_h)

          logger.warn "Failed to create generation" if response["successes"].blank?

          generation
        end

        def generation(**kwargs)
          generation = TraceTypes::Generation.new(id: SecureRandom.uuid, tracer: self, **kwargs)
          response = client.create_generation(generation.to_h)
          logger.warn "Failed to create generation" if response["successes"].blank?

          return generation unless block_given?

          result = yield generation

          end_generation(generation, result)

          result
        end

        private

        def logger
          @logger ||= Logger.new($stdout)
        end

        def client
          @client ||= ApiClients::Langfuse.new(**LlmEvalRuby.config.langfuse_options)
        end

        def end_span(span, result)
          span.end_time = Time.now.utc.iso8601
          span.output = result

          client.update_span(span.to_h)
        end

        def end_generation(generation, result)
          generation.output = result.dig("choices", 0, "message", "content")
          generation.usage = result["usage"]
          generation.end_time = Time.now.utc.iso8601

          client.update_generation(generation.to_h)
        end
      end
    end
  end
end
