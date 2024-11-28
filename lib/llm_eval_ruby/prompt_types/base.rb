# frozen_string_literal: true

module LlmEvalRuby
  module PromptTypes
    class Base
      attr_reader :role, :content

      def initialize(adapter:, content:, role:)
        @adapter = adapter
        @role = role
        @content = content
      end

      def to_h
        { role: role, content: content }
      end

      def to_s
        content
      end

      def compile(variables:)
        @adapter.compile(prompt: self, variables: variables)
      end
    end
  end
end
