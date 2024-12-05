# frozen_string_literal: true

class GenerationSerializer < ActiveJob::Serializers::ObjectSerializer
  def serialize(generation)
    super({
      "id" => generation.id,
      "name" => generation.name,
      "input" => generation.input,
      "prompt_name" => generation.prompt_name,
      "prompt_version" => generation.prompt_version,
      "trace_id" => generation.trace_id,
      "output" => generation.output,
      "end_time" => generation.end_time,
      "usage" => generation.usage
    })
  end

  def deserialize(hash)
    klass.new(
      tracer: hash["tracer"],
      id: hash["id"],
      name: hash["name"],
      input: hash["input"],
      prompt_name: hash["prompt_name"],
      prompt_version: hash["prompt_version"],
      trace_id: hash["trace_id"],
      output: hash["output"],
      end_time: hash["end_time"],
      usage: hash["usage"]
    )
  end

  private

  def klass
    LlmEvalRuby::TraceTypes::Generation
  end
end
