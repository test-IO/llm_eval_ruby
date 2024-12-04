# frozen_string_literal: true

class TraceSerializer < ActiveJob::Serializers::ObjectSerializer
  def serialize(trace)
    super({
      "id" => trace.id,
      "session_id" => trace.session_id
    })
  end

  def deserialize(hash)
    klass.new(
      id: hash["id"],
      session_id: hash["session_id"]
    )
  end

  private

  def klass
    LlmEvalRuby::TraceTypes::Trace
  end
end
