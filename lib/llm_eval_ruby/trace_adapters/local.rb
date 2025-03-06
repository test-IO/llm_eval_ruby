# frozen_string_literal: true

require_relative "base"

module LlmEvalRuby
  module TraceAdapters
    class Local < Base
      class << self
        def trace(**kwargs)
          trace = TraceTypes::Trace.new(id: SecureRandom.uuid, **kwargs)

          logger.info("Trace created: #{JSON.pretty_generate(trace.to_h)}")

          trace
        end

        def span(**kwargs)
          span = TraceTypes::Span.new(id: SecureRandom.uuid, **kwargs)

          logger.info("Span created: #{JSON.pretty_generate(span.to_h)}")

          return span unless block_given?

          result = yield span

          end_span(span, result)

          result
        end

        def update_generation(**kwargs)
          generation = TraceTypes::Generation.new(**kwargs)

          logger.info("Generation updated: #{JSON.pretty_generate(generation.to_h)}")

          generation
        end

        def generation(**kwargs)
          generation = TraceTypes::Generation.new(id: SecureRandom.uuid, tracer: self, **kwargs)

          logger.info("Generation created: #{JSON.pretty_generate(generation.to_h)}")

          return generation unless block_given?

          result = yield generation

          end_generation(generation, result)

          result
        end

        private

        def logger
          @logger ||= ActiveSupport::Logger.new(LlmEvalRuby.config.local_options[:traces_path])
        end

        def end_span(span, result)
          span.end_time = Time.now.utc.iso8601
          span.output = result

          logger.info("Span updated: #{JSON.pretty_generate(span.to_h)}")
        end

        def end_generation(generation, result)
          generation.output = result.dig("choices", 0, "message", "content")
          generation.usage = result["usage"]
          generation.end_time = Time.now.utc.iso8601

          logger.info("Generation updated: #{JSON.pretty_generate(generation.to_h)}")
        end
      end
    end
  end
end
