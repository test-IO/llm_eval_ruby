# frozen_string_literal: true

require_relative "base"

module LlmEvalRuby
  module PromptTypes
    class User < Base
      def initialize(adapter:, content:)
        super(adapter: adapter, content: content, role: :user)
      end
    end
  end
end
