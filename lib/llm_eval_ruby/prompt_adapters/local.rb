# frozen_string_literal: true

require "liquid"
require_relative "base"

module LlmEvalRuby
  module PromptAdapters
    class Local < Base
      class << self
        # Versioning was introduced to allow flexibility in managing different iterations of prompts.
        # This enables testing and gradual rollouts of updated prompt versions without affecting existing ones.
        #
        # lib/prompts/test
        # ├── system.txt
        # ├── user.txt
        # └── v2
        #     ├── system.txt
        #     └── user.txt
        # └── v3
        #     ├── system.txt
        #     └── user.txt
        def fetch_prompt(name:, version: nil) # rubocop:disable Lint/UnusedMethodArgument
          prompt_path = Rails.root.join(LlmEvalRuby.config.local_options[:prompts_path], name.to_s, version.to_s)

          system_prompts = Dir.glob("#{prompt_path}/system.txt").map do |path|
            { "role" => "system", "content" => File.read(path) }
          end

          user_prompt = Dir.glob("#{prompt_path}/user*.txt").map do |path|
            { "role" => "user", "content" => File.read(path) }
          end

          handle_response(system_prompts + user_prompt)
        end
      end
    end
  end
end
