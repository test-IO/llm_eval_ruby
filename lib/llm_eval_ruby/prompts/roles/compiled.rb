# frozen_string_literal: true

module LlmEvalRuby
  module Prompts
    module Roles
      class Compiled
        attr_reader :role, :content

        def initialize(content:, role:)
          @role = role
          @content = content
        end

        def to_h
          { role: role, content: content }
        end

        def to_s
          content
        end
      end
    end
  end
end
