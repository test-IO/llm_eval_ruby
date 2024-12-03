# frozen_string_literal: true

require_relative "base"
require_relative "../api_clients/langfuse"
require_relative "../trace_types"

module LlmEvalRuby
  module TraceAdapters
    class Langfuse < Base
      class << self
        def trace(**)
          trace = TraceTypes::Trace.new(id: SecureRandom.uuid, **)
          response = client.create_trace(trace.to_h)

          Rails.logger.warn "Failed to create generation" if response["successes"].blank?

          trace
        end

        def span(**)
          span = TraceTypes::Span.new(id: SecureRandom.uuid, **)
          response = client.create_span(span.to_h)

          Rails.logger.warn "Failed to create span" if response["successes"].blank?

          if block_given?
            result = yield

            span.end_time = Time.now.utc.iso8601
            span.output = result

            client.update_span(span.to_h)
          else
            span
          end
        end

        def update_generation(**)
          generation = TraceTypes::Generation.new(**)
          response = client.update_generation(generation.to_h)

          Rails.logger.warn "Failed to create generation" if response["successes"].blank?

          generation
        end

        def generation(**)
          generation = TraceTypes::Generation.new(id: SecureRandom.uuid, tracer: self, **)
          response = client.create_generation(generation.to_h)
          Rails.logger.warn "Failed to create generation" if response["successes"].blank?

          if block_given?
            result = yield generation

            generation.end_time = Time.now.utc.iso8601
            generation.output = result.dig("choices", 0, "message", "content")
            generation.usage = result["usage"]

            client.update_generation(generation.to_h)
          else
            generation
          end
        end

        private

        def client
          @client ||= ApiClients::Langfuse.new(**LlmEvalRuby.config.langfuse_options)
        end
      end
    end
  end
end
