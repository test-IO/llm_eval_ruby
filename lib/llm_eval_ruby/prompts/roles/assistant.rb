# frozen_string_literal: true

require_relative "base"

module LlmEvalRuby
  module Prompts
    module Roles
      class Assistant < Base
        def initialize(adapter:, content:)
          super(adapter: adapter, content: content, role: :assistant)
        end
      end
    end
  end
end
