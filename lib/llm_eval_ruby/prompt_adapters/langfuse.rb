# frozen_string_literal: true

require_relative "../api_clients/langfuse"

module LlmEvalRuby
  module PromptAdapters
    class Langfuse
      class << self
        def fetch_prompt(name:, version: nil)
          client.fetch_prompt(name:, version:)
        end

        def compile(name:, variables:, version: nil)
          prompt = fetch_prompt(name:, version:)
          format(convert_prompt(prompt), variables)
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
