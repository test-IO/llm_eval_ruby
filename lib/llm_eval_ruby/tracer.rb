# frozen_string_literal: true

module LlmEvalRuby
  class Tracer
    attr_reader :client

    Generation = Struct.new(:tracer,
                            :id,
                            :name,
                            :trace_id,
                            :input,
                            :output,
                            :end_time,
                            :prompt_name,
                            :prompt_version,
                            keyword_init: true) do
      def end(output:)
        self.output = output
        self.end_time = Time.now.utc.iso8601

        tracer.update_generation(**to_h)
      end
    end

    Trace = Struct.new(:id, :name, :session_id, keyword_init: true)
    Span = Struct.new(:id, :name, :trace_id, :output, :end_time, keyword_init: true)

    def initialize(client = ApiClients::Langfuse.new(**LlmEvalRuby.config.langfuse_options))
      @client = client
    end

    def trace(**)
      trace = Trace.new(id: SecureRandom.uuid, **)
      response = client.create_trace(trace.to_h)

      Rails.logger.warn "Failed to create generation" if response["successes"].blank?

      trace
    end

    def span(**)
      span = Span.new(id: SecureRandom.uuid, **)
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
      generation = Generation.new(**)
      response = client.update_generation(generation.to_h)

      Rails.logger.warn "Failed to create generation" if response["successes"].blank?

      generation
    end

    def generation(**)
      generation = Generation.new(id: SecureRandom.uuid, tracer: self, **)
      response = client.create_generation(generation.to_h)
      Rails.logger.warn "Failed to create generation" if response["successes"].blank?

      if block_given?
        result = yield

        generation.end_time = Time.now.utc.iso8601
        generation.output = result

        client.update_generation(generation.to_h)
      else
        generation
      end
    end
  end
end
