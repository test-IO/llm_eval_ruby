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
        self.class.base_uri "#{host}/api/public/"
        self.class.basic_auth username, password
      end

      def fetch_prompt(name:, version:)
        response = self.class.get("/v2/prompts/#{name}", { query: { version: } })
        response["prompt"]
      end

      # We are using the same method for updating trace
      # Langfuse does an upsert if id is given
      def create_trace(params = {})
        body = {
          id: params[:id]
        }
        body[:name] = params[:name] if params[:name]
        body[:input] = params[:input] if params[:input]
        body[:sessionId] = params[:session_id] if params[:session_id]
        body[:userId] = params[:user_id] if params[:user_id]
        body[:metadata] = params[:metadata] if params[:metadata]
        body[:output] = params[:output] if params[:output]

        create_event(type: "trace-create", body:)
      end

      def create_span(params = {})
        body = {
          id: params[:id],
          name: params[:name],
          input: params[:input],
          traceId: params[:trace_id],
          metadata: params[:metadata] || {}
        }
        create_event(type: "span-create", body:)
      end

      def update_span(params = {})
        body = {
          id: params[:id],
          output: params[:output],
          endTime: params[:end_time],
          metadata: params[:metadata] || {}
        }
        create_event(type: "span-update", body:)
      end

      def create_generation(params = {})
        body = {
          id: params[:id],
          timestamp: params[:timestamp],
          name: params[:name],
          input: params[:input],
          output: params[:output] || "UNKNOWN",
          traceId: params[:trace_id],
          release: params[:release] || "UNKNOWN",
          version: params[:version] || "UNKNOWN",
          metadata: params[:metadata] || {},
          model: params[:model] || "UNKNOWN",
          promptName: params[:prompt_name],
          promptVersion: params[:prompt_version]
        }
        create_event(type: "generation-create", body:)
      end

      def update_generation(params = {})
        body = {
          id: params[:id],
          output: params[:output],
          endTime: params[:end_time],
          usage: convert_keys_to_camel_case(params[:usage]),
          metadata: params[:metadata] || {}
        }
        create_event(type: "generation-update", body:)
      end

      def create_event(type:, body:)
        payload = {
          batch: [
            {
              id: SecureRandom.uuid,
              type:,
              body: body.deep_stringify_keys,
              timestamp: Time.now.utc.iso8601,
              metadata: {}
            }
          ]
        }

        self.class.post("/ingestion", body: payload.to_json)
      end

      private

      def convert_keys_to_camel_case(hash)
        hash.each_with_object({}) do |(key, value), new_hash|
          camel_case_key = key.gsub(/_([a-z])/) { ::Regexp.last_match(1).upcase }
          new_hash[camel_case_key] = value
        end
      end
    end
  end
end
