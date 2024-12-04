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

      Array[*args, **kwargs].flatten
    end
  end
end
