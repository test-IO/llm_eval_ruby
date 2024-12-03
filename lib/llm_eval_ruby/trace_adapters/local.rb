# frozen_string_literal: true

require_relative "base"

module LlmEvalRuby
  module TraceAdapters
    class Local < Base
      class << self
        def trace(**)
          trace = TraceTypes::Trace.new(id: SecureRandom.uuid, **)

          logger.info("Trace created: #{JSON.pretty_generate(trace.to_h)}")

          trace
        end

        def span(**)
          span = TraceTypes::Span.new(id: SecureRandom.uuid, **)

          logger.info("Span created: #{JSON.pretty_generate(span.to_h)}")

          if block_given?
            result = yield

            span.end_time = Time.now.utc.iso8601
            span.output = result

            logger.info("Span updated: #{JSON.pretty_generate(span.to_h)}")
          else
            span
          end
        end

        def update_generation(**)
          generation = TraceTypes::Generation.new(**)

          logger.info("Generation updated: #{JSON.pretty_generate(generation.to_h)}")

          generation
        end

        def generation(**)
          generation = TraceTypes::Generation.new(id: SecureRandom.uuid, tracer: self, **)

          logger.info("Generation created: #{JSON.pretty_generate(generation.to_h)}")

          if block_given?
            result = yield

            generation.end_time = Time.now.utc.iso8601
            generation.output = result

            logger.info("Generation updated: #{JSON.pretty_generate(generation.to_h)}")
          else
            generation
          end
        end

        def logger
          @logger ||= ActiveSupport::Logger.new(LlmEvalRuby.config.local_options[:traces_path])
        end
      end
    end
  end
end
