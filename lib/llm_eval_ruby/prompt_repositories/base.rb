# frozen_string_literal: true

require_relative "../prompt_adapters/langfuse"
require_relative "../prompt_adapters/local"

module LlmEvalRuby
  module PromptRepositories
    class Base
      attr_reader :adapter

      def self.fetch(name:, version: nil)
        new(adapter: LlmEvalRuby.config.adapter).fetch(name: name, version: version)
      end

      def self.fetch_and_compile(name:, variables:, version: nil)
        new(adapter: LlmEvalRuby.config.adapter).fetch_and_compile(name: name, variables: variables, version: version)
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

      def fetch_and_compile(name:, variables:, version: nil)
        raise NotImplementedError
      end
    end
  end
end
