# frozen_string_literal: true

require_relative "base"

module LlmEvalRuby
  module Prompts
    module Roles
      class System < Base
        def initialize(adapter: ,content:)
          super(adapter: adapter, content: content, role: :system)
        end
      end
    end
  end
end
