# frozen_string_literal: true

require_relative "base"
require_relative "../api_clients/langfuse"

module LlmEvalRuby
  module PromptAdapters
    class Langfuse < Base
      def initialize(client: nil)
        super()
        @client = client
      end

      def fetch_prompt(name:, version: nil)
        response = client.fetch_prompt(name:, version:)
        self.class.handle_response(response)
      end

      def compile(prompt:, variables:)
        self.class.compile(prompt:, variables:)
      end

      private

      def client
        @client ||= ApiClients::Langfuse.new(**LlmEvalRuby.config.langfuse_options)
      end
    end
  end
end
