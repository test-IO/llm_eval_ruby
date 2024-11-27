# frozen_string_literal: true

require_relative "base"

module LlmEvalRuby
  module Prompts
    class Text < Base
      def fetch(name:, version: nil)
        adapter.fetch_prompt(name:, version:)[0]
      end
  
      def compile(name:, variables:, version: nil)
        prompt = adapter.fetch_prompt(name:, version:)[0]
        adapter.compile(prompt:, variables:)
      end
    end    
  end
end
