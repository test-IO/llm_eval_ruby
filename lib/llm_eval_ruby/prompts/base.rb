# frozen_string_literal: true

require_relative "../prompt_adapters/langfuse"
require_relative "../prompt_adapters/local"

module LlmEvalRuby
  module Prompts
    class Base
      attr_reader :adapter
  
      def self.fetch(name:, version: nil)
        new(adapter: LlmEvalRuby.config.adapter).fetch(name: name, version: version)
      end
  
      def self.compile(name:, variables:, version: nil)
        new(adapter: LlmEvalRuby.config.adapter).compile(name: name, variables: variables, version: version)
      end
  
      def initialize(adapter:)
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
        raise NotImplementedError
      end
  
      def compile(name:, variables:, version: nil)
        raise NotImplementedError
      end
    end
  end
end
