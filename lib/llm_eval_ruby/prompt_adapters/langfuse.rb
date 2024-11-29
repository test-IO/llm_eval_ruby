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

        private

        def client
          @client ||= ApiClients::Langfuse.new(**LlmEvalRuby.config.langfuse_options)
        end
      end
    end
  end
end
