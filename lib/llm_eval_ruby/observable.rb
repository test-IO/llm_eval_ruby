# frozen_string_literal: true

module LlmEvalRuby
  module Observable
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def observed_methods
        @observed_methods ||= {}
      end

      def observe(method_name, options = {})
        observed_methods[method_name] = options
      end

      def method_added(method_name)
        return unless observed_methods.key?(method_name)

        options = observed_methods[method_name]

        original_method = instance_method(method_name)
        observed_methods.delete(method_name)

        define_method(method_name) do |*args, **kwargs, &block|
          result = nil
          input = prepare_input(args, kwargs)
          case options[:type]
          when :span
            LlmEvalRuby::Tracer.span(name: method_name, input: input, trace_id: @trace_id) do
              result = original_method.bind(self).call(*args, **kwargs, &block)
            end
          when :generation
            LlmEvalRuby::Tracer.generation(name: method_name, input: input, trace_id: @trace_id) do
              result = original_method.bind(self).call(*args, **kwargs, &block)
            end
          else
            LlmEvalRuby::Tracer.trace(name: method_name, input: input, trace_id: @trace_id) do
              result = original_method.bind(self).call(*args, **kwargs, &block)
            end
          end

          result
        end
      end
    end

    def prepare_input(*args, **kwargs)
      return nil if args.empty? && kwargs.empty?

      inputs = deep_copy(Array[*args, **kwargs].flatten)
      inputs.each do |item|
        trim_base64_images(item) if item.is_a?(Hash)
      end

      inputs
    end

    def trim_base64_images(hash, max_length = 30)
      # Iterate through each key-value pair in the hash
      hash.each do |key, value|
        if value.is_a?(Hash)
          # Recursively process nested hashes
          trim_base64_images(value, max_length)
        elsif value.is_a?(String) && value.start_with?("data:image/jpeg;base64,")
          # Trim the byte string while keeping the prefix; set max length limit
          prefix = "data:image/jpeg;base64,"
          byte_string = value[prefix.length..-1]
          trimmed_byte_string = byte_string[0, max_length] # Trim to max_length characters
          hash[key] = "#{prefix}#{trimmed_byte_string}... (truncated)"
        elsif value.is_a?(Array)
          # Recursively process arrays
          value.each do |element|
            trim_base64_images(element, max_length) if element.is_a?(Hash)
          end
        end
      end
      hash
    end

    def deep_copy(obj)
      case obj
      when Numeric, Symbol, NilClass, TrueClass, FalseClass
        obj
      when String
        obj.dup
      when Array
        obj.map { |e| deep_copy(e) }
      when Hash
        obj.each_with_object({}) do |(key, value), result|
          result[deep_copy(key)] = deep_copy(value)
        end
      else
        begin
          Marshal.load(Marshal.dump(obj))
        rescue TypeError
          nil # or handle as needed, perhaps log or raise a specific error
        end
      end
    end
  end
end
