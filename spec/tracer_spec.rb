# frozen_string_literal: true

RSpec.describe LlmEvalRuby::Tracer do
  let(:default_langfuse_options) do
    {
      host: "https://default.langfuse.com",
      username: "default_key",
      password: "default_secret"
    }
  end

  let(:custom_client) { instance_double(LlmEvalRuby::ApiClients::Langfuse) }
  let(:trace_response) { { "successes" => [{ "id" => "trace-123" }] } }
  let(:span_response) { { "successes" => [{ "id" => "span-123" }] } }
  let(:generation_response) { { "successes" => [{ "id" => "gen-123" }] } }

  before do
    LlmEvalRuby.configure do |config|
      config.adapter = :langfuse
      config.langfuse_options = default_langfuse_options
    end
  end

  describe "#initialize" do
    context "with custom client" do
      it "uses the provided client" do
        tracer = described_class.new(adapter: :langfuse, client: custom_client)
        expect(tracer.adapter).to be_a(LlmEvalRuby::TraceAdapters::Langfuse)
      end
    end

    context "without custom client" do
      it "creates a default client from config" do
        tracer = described_class.new(adapter: :langfuse)
        expect(tracer.adapter).to be_a(LlmEvalRuby::TraceAdapters::Langfuse)
      end
    end

    context "with local adapter" do
      it "uses Local adapter class" do
        tracer = described_class.new(adapter: :local)
        expect(tracer.adapter).to eq(LlmEvalRuby::TraceAdapters::Local)
      end
    end
  end

  describe "#trace" do
    context "with custom client" do
      it "uses the custom client to create trace" do
        allow(custom_client).to receive(:create_trace).and_return(trace_response)

        tracer = described_class.new(adapter: :langfuse, client: custom_client)
        result = tracer.trace(name: "test_trace", input: { query: "test" })

        expect(custom_client).to have_received(:create_trace)
        expect(result).to be_a(LlmEvalRuby::TraceTypes::Trace)
        expect(result.name).to eq("test_trace")
      end
    end
  end

  describe "#span" do
    context "with custom client" do
      it "uses the custom client to create span" do
        allow(custom_client).to receive(:create_span).and_return(span_response)

        tracer = described_class.new(adapter: :langfuse, client: custom_client)
        result = tracer.span(name: "test_span", trace_id: "trace-123", input: { data: "test" })

        expect(custom_client).to have_received(:create_span)
        expect(result).to be_a(LlmEvalRuby::TraceTypes::Span)
        expect(result.name).to eq("test_span")
      end

      it "updates span when block is given" do
        allow(custom_client).to receive(:create_span).and_return(span_response)
        allow(custom_client).to receive(:update_span).and_return(span_response)

        tracer = described_class.new(adapter: :langfuse, client: custom_client)
        result = tracer.span(name: "test_span", trace_id: "trace-123", input: { data: "test" }) do
          "block_result"
        end

        expect(custom_client).to have_received(:create_span)
        expect(custom_client).to have_received(:update_span)
        expect(result).to eq("block_result")
      end
    end
  end

  describe "#generation" do
    context "with custom client" do
      it "uses the custom client to create generation" do
        allow(custom_client).to receive(:create_generation).and_return(generation_response)

        tracer = described_class.new(adapter: :langfuse, client: custom_client)
        result = tracer.generation(
          name: "test_generation",
          trace_id: "trace-123",
          input: { prompt: "test" },
          model: "gpt-4"
        )

        expect(custom_client).to have_received(:create_generation)
        expect(result).to be_a(LlmEvalRuby::TraceTypes::Generation)
        expect(result.name).to eq("test_generation")
      end

      it "updates generation when block is given" do
        allow(custom_client).to receive(:create_generation).and_return(generation_response)
        allow(custom_client).to receive(:update_generation).and_return(generation_response)

        tracer = described_class.new(adapter: :langfuse, client: custom_client)
        llm_response = {
          "choices" => [{ "message" => { "content" => "AI response" } }],
          "usage" => { "prompt_tokens" => 10, "completion_tokens" => 20 }
        }
        result = tracer.generation(
          name: "test_generation",
          trace_id: "trace-123",
          input: { prompt: "test" },
          model: "gpt-4"
        ) { llm_response }

        expect(custom_client).to have_received(:create_generation)
        expect(custom_client).to have_received(:update_generation)
        expect(result).to eq(llm_response)
      end
    end
  end

  describe "#update_generation" do
    context "with custom client" do
      it "uses the custom client to update generation" do
        allow(custom_client).to receive(:update_generation).and_return(generation_response)

        tracer = described_class.new(adapter: :langfuse, client: custom_client)
        result = tracer.update_generation(
          id: "gen-123",
          output: { response: "result" },
          usage: { prompt_tokens: 10, completion_tokens: 20 }
        )

        expect(custom_client).to have_received(:update_generation)
        expect(result).to be_a(LlmEvalRuby::TraceTypes::Generation)
      end
    end
  end

  describe "class methods" do
    it "delegates to instance with default adapter" do
      allow_any_instance_of(LlmEvalRuby::ApiClients::Langfuse)
        .to receive(:create_trace).and_return(trace_response)

      result = described_class.trace(name: "class_method_trace", input: { query: "test" })

      expect(result).to be_a(LlmEvalRuby::TraceTypes::Trace)
      expect(result.name).to eq("class_method_trace")
    end
  end
end
