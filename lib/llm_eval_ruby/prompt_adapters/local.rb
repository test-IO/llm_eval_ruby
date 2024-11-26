# frozen_string_literal: true

module LlmEvalRuby
  module PromptAdapters
    class Local
      class << self
        def fetch_prompt(name:, version: nil)
          prompt_path = Rails.root.join(LlmEvalRuby.config.local_options['promts_paths'], "#{name}.txt")
          File.read(prompt_path)
        end
  
        def compile(name:, version:, variables:)
          prompt = fetch_prompt(name:, version:)
          format(convert_prompt(prompt), variables)
        end
  
        private
  
        def convert_prompt(prompt) # convert {{variable}} to %<variable>s
          prompt.gsub(/\{\{([^}]+)\}\}/, '%<\1>s')
        end
      end
    end
  end
end
