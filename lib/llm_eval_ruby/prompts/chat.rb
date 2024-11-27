# frozen_string_literal: true

require_relative "base"

module LlmEvalRuby
  module Prompts
    class Chat < Base
      def fetch(name:, version: nil)
        adapter.fetch_prompt(name:, version:)
      end

      def fetch_and_compile(name:, variables:, version: nil)
        prompts = adapter.fetch_prompt(name:, version:)

        prompts.map do |prompt|
          adapter.compile(prompt:, variables:)
        end
      end
    end
  end
end
