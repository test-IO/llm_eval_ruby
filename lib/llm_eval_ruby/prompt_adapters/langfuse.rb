# frozen_string_literal: true

require_relative "base"
require_relative "../api_clients/langfuse"

module LlmEvalRuby
  module PromptAdapters
    class Langfuse < Base
      class << self
        def fetch_prompt(name:, version: nil)
          response = client.fetch_prompt(name:, version:)
          handle_response(response)
        end

        def compile(prompt:, variables:)
          compiled = format(convert_prompt(prompt.content), variables)
          LlmEvalRuby::PromptTypes::Compiled.new(adapter: self, role: prompt.role, content: compiled)
        end

        private

        def client
          @client ||= ApiClients::Langfuse.new(**LlmEvalRuby.config.langfuse_options)
        end

        # convert {{variable}} to %<variable>s
        def convert_prompt(prompt)
          prompt.gsub(/\{\{([^}]+)\}\}/, '%<\1>s')
        end
      end
    end
  end
end
