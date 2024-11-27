# frozen_string_literal: true

require_relative "base"

module LlmEvalRuby
  module Prompts
    class Chat < Base
      def fetch(name:, version: nil)
        prompts = adapter.fetch_prompt(name:, version:)
      end
  
      def compile(name:, variables:, version: nil)
        prompts = adapter.fetch_prompt(name:, version:)
       
        prompts.map do |prompt|
          adapter.compile(prompt:, variables:)
        end
      end
    end
  end
end
