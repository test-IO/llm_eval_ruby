# frozen_string_literal: true

require_relative "../prompts/roles/user"
require_relative "../prompts/roles/system"
require_relative "../prompts/roles/assistant"

module LlmEvalRuby
  module PromptAdapters
    class Base
      class << self
        def fetch_prompt(name:, version: nil)
          raise NotImplementedError
        end

        def compile(prompt:, variables:)
          raise NotImplementedError
        end

        private

        def handle_response(response)
          response.is_a?(Array) ? wrap_response(response) : wrap_response({'role' => 'system', 'content' => response})
        end

        def wrap_response(response)
          response_array = response.is_a?(Array) ? response : [response]

          response_array.map do |prompt|
            case prompt['role']
            when 'system'
              LlmEvalRuby::Prompts::Roles::System.new(adapter: self, content: prompt['content'])
            when 'user'
              LlmEvalRuby::Prompts::Roles::User.new(adapter: self, content: prompt['content'])
            when 'assistant'
              LlmEvalRuby::Prompts::Roles::Assistant.new(adapter: self, content: prompt['content'])
            else
              raise "Unsupported role #{prompt['role']}"
            end
          end
        end
      end
    end
  end
end
