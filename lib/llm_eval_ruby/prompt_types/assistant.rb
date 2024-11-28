# frozen_string_literal: true

require_relative "base"

module LlmEvalRuby
  module PromptTypes
    class Assistant < Base
      def initialize(adapter:, content:)
        super(adapter: adapter, content: content, role: :assistant)
      end
    end
  end
end
