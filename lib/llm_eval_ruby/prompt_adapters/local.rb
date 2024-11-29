# frozen_string_literal: true

require "liquid"
require_relative "base"

module LlmEvalRuby
  module PromptAdapters
    class Local < Base
      class << self
        def fetch_prompt(name:, version: nil) # rubocop:disable Lint/UnusedMethodArgument
          prompt_path = Rails.root.join(LlmEvalRuby.config.local_options[:prompts_path], name.to_s)

          system_prompts = Dir.glob("#{prompt_path}/**/system.txt").map do |path|
            { "role" => "system", "content" => File.read(path) }
          end

          user_prompt = Dir.glob("#{prompt_path}/**/user*.txt").map do |path|
            { "role" => "user", "content" => File.read(path) }
          end

          handle_response(system_prompts + user_prompt)
        end
      end
    end
  end
end
