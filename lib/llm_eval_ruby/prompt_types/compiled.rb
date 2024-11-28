# frozen_string_literal: true

module LlmEvalRuby
  module PromptTypes
    class Compiled < Base
      def compile(*)
        raise "The prompt is already compiled"
      end
    end
  end
end
