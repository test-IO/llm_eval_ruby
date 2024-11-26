# frozen_string_literal: true

require_relative "../api_clients/langfuse"

module LlmEvalRuby
  module PromptAdapters
    class Langfuse
      class << self
        def fetch_prompt(name:, version: nil)
          client.fetch_prompt(name:, version:)
        end

        def compile(name:, version:, variables:)
          prompt = fetch_prompt(name:, version:)
          format(convert_prompt(prompt), variables)
        end

        private

        def client
          @client ||= ApiClients::Langfuse.new(**LlmEvalRuby.config.langfuse_options)
        end

        def convert_prompt(prompt) # convert {{variable}} to %<variable>s
          prompt.gsub(/\{\{([^}]+)\}\}/, '%<\1>s')
        end
      end
    end
  end
end
