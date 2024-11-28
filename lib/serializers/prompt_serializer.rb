# frozen_string_literal: true

class PromptSerializer < ActiveJob::Serializers::ObjectSerializer
  def serialize(prompt)
    super({
      "role" => prompt.role,
      "content" => prompt.content,
      "adapter" => prompt.instance_variable_get(:@adapter)
    })
  end

  def deserialize(hash)
    case hash["role"]
    when "user"
      klass = LlmEvalRuby::PromptTypes::User
    when "system"
      klass = LlmEvalRuby::PromptTypes::System
    when "assistant"
      klass = LlmEvalRuby::PromptTypes::Assistant
    else
      raise "Unsupported role #{role}"
    end

    klass.new(adapter: hash["adapter"], content: hash["content"])
  end

  private

  def klass
    LlmEvalRuby::PromptTypes::Base
  end
end
