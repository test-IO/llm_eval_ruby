# frozen_string_literal: true

require "httparty"

module LlmEvalRuby
  module ApiClients
    class Langfuse
      include HTTParty

      headers "Content-Type" => "application/json"

      format :json

      raise_on [400, 401, 406, 422, 500]

      def initialize(host:, username:, password:)
        self.class.base_uri "#{host}/api/public/v2"
        self.class.basic_auth username, password
      end

      def fetch_prompt(name:, version:)
        response = self.class.get("/prompts/#{name}", { query: { version: } })
        response["prompt"]
      end
    end
  end
end
