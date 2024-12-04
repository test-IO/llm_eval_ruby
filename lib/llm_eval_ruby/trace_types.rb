# frozen_string_literal: true

module LlmEvalRuby
  module TraceTypes
    Trace = Struct.new(:id, :name, :input, :output, :session_id, keyword_init: true)

    Span = Struct.new(:id, :name, :trace_id, :input, :output, :end_time, keyword_init: true)

    Generation = Struct.new(:tracer,
                            :id,
                            :name,
                            :trace_id,
                            :input,
                            :output,
                            :end_time,
                            :prompt_name,
                            :prompt_version,
                            :usage,
                            keyword_init: true) do
      def end(output:, usage: nil)
        self.output = output
        self.end_time = Time.now.utc.iso8601
        self.usage = convert_keys_to_camel_case(usage) if usage

        tracer.update_generation(**to_h)
      end

      def convert_keys_to_camel_case(hash)
        hash.each_with_object({}) do |(key, value), new_hash|
          camel_case_key = key.gsub(/_([a-z])/) { ::Regexp.last_match(1).upcase }
          new_hash[camel_case_key] = value
        end
      end
    end
  end
end
