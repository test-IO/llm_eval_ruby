# frozen_string_literal: true

require_relative "base"

module LlmEvalRuby
  module PromptAdapters
    class Local < Base
      class << self
        def fetch_prompt(name:, version: nil) # rubocop:disable Lint/UnusedMethodArgument
          prompt_path = Rails.root.join(LlmEvalRuby.config.local_options[:prompts_path], "#{name}.txt")
          File.read(prompt_path)
        end

        def compile(name:, variables:, version: nil)
          prompt = fetch_prompt(name:, version:)
          format(convert_prompt(prompt), variables)
        end

        private

        # convert {{variable}} to %<variable>s
        def convert_prompt(prompt)
          prompt.gsub(/\{\{([^}]+)\}\}/, '%<\1>s')
        end
      end
    end
  end
end
