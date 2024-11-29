# frozen_string_literal: true

require_relative "../prompt_types/user"
require_relative "../prompt_types/system"
require_relative "../prompt_types/assistant"
require_relative "../prompt_types/compiled"

module LlmEvalRuby
  module PromptAdapters
    class Base
      class << self
        def fetch_prompt(name:, version: nil)
          raise NotImplementedError
        end

        def compile(prompt:, variables:)
          compiled = render_template(prompt.content, variables)
          LlmEvalRuby::PromptTypes::Compiled.new(adapter: self, role: prompt.role, content: compiled)
        end

        private

        def handle_response(response)
          response.is_a?(Array) ? wrap_response(response) : wrap_response({ "role" => "system", "content" => response })
        end

        def wrap_response(response)
          response_array = response.is_a?(Array) ? response : [response]

          response_array.map do |prompt|
            case prompt["role"]
            when "system"
              PromptTypes::System.new(adapter: self, content: prompt["content"])
            when "user"
              PromptTypes::User.new(adapter: self, content: prompt["content"])
            when "assistant"
              PromptTypes::Assistant.new(adapter: self, content: prompt["content"])
            else
              raise "Unsupported role #{prompt["role"]}"
            end
          end
        end

        def render_template(template, variables)
          template = Liquid::Template.parse(template)
          template.render(variables.stringify_keys)
        end
      end
    end
  end
end
