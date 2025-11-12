# frozen_string_literal: true

RSpec.describe LlmEvalRuby::PromptRepositories::Text do
  let(:default_langfuse_options) do
    {
      host: "https://default.langfuse.com",
      username: "default_key",
      password: "default_secret"
    }
  end

  let(:custom_client) { instance_double(LlmEvalRuby::ApiClients::Langfuse) }

  let(:prompt_response) do
    [
      {
        "role" => "user",
        "content" => "Hello {{ name }}"
      }
    ]
  end

  before do
    LlmEvalRuby.configure do |config|
      config.adapter = :langfuse
      config.langfuse_options = default_langfuse_options
    end
  end

  describe "#initialize" do
    context "with custom client" do
      it "creates instance with custom Langfuse adapter" do
        repo = described_class.new(adapter: :langfuse, client: custom_client)
        expect(repo.adapter).to be_a(LlmEvalRuby::PromptAdapters::Langfuse)
      end
    end

    context "without custom client" do
      it "creates instance with default Langfuse adapter" do
        repo = described_class.new(adapter: :langfuse)
        expect(repo.adapter).to be_a(LlmEvalRuby::PromptAdapters::Langfuse)
      end
    end

    context "with local adapter" do
      it "uses Local adapter class" do
        repo = described_class.new(adapter: :local)
        expect(repo.adapter).to eq(LlmEvalRuby::PromptAdapters::Local)
      end
    end
  end

  describe "#fetch" do
    context "with custom client" do
      it "uses the custom client to fetch prompt" do
        allow(custom_client).to receive(:fetch_prompt)
          .with(name: "my_prompt", version: nil)
          .and_return(prompt_response)

        repo = described_class.new(adapter: :langfuse, client: custom_client)
        result = repo.fetch(name: "my_prompt")

        expect(custom_client).to have_received(:fetch_prompt)
        expect(result).to be_a(LlmEvalRuby::PromptTypes::User)
        expect(result.content).to eq("Hello {{ name }}")
      end

      it "uses custom client with version parameter" do
        allow(custom_client).to receive(:fetch_prompt)
          .with(name: "my_prompt", version: "v1.0")
          .and_return(prompt_response)

        repo = described_class.new(adapter: :langfuse, client: custom_client)
        result = repo.fetch(name: "my_prompt", version: "v1.0")

        expect(custom_client).to have_received(:fetch_prompt).with(name: "my_prompt", version: "v1.0")
        expect(result).to be_a(LlmEvalRuby::PromptTypes::User)
      end
    end
  end

  describe "#fetch_and_compile" do
    context "with custom client" do
      it "uses the custom client and compiles with variables" do
        allow(custom_client).to receive(:fetch_prompt)
          .with(name: "my_prompt", version: nil)
          .and_return(prompt_response)

        repo = described_class.new(adapter: :langfuse, client: custom_client)
        result = repo.fetch_and_compile(name: "my_prompt", variables: { name: "Alice" })

        expect(custom_client).to have_received(:fetch_prompt)
        expect(result).to be_a(LlmEvalRuby::PromptTypes::Compiled)
        expect(result.content).to eq("Hello Alice")
      end

      it "uses custom client with version parameter" do
        allow(custom_client).to receive(:fetch_prompt)
          .with(name: "my_prompt", version: "v2.0")
          .and_return(prompt_response)

        repo = described_class.new(adapter: :langfuse, client: custom_client)
        result = repo.fetch_and_compile(
          name: "my_prompt",
          variables: { name: "Bob" },
          version: "v2.0"
        )

        expect(custom_client).to have_received(:fetch_prompt).with(name: "my_prompt", version: "v2.0")
        expect(result.content).to eq("Hello Bob")
      end
    end
  end

  describe "class methods" do
    it "delegates to instance with default adapter" do
      allow_any_instance_of(LlmEvalRuby::ApiClients::Langfuse)
        .to receive(:fetch_prompt)
        .with(name: "my_prompt", version: nil)
        .and_return(prompt_response)

      result = described_class.fetch(name: "my_prompt")

      expect(result).to be_a(LlmEvalRuby::PromptTypes::User)
      expect(result.content).to eq("Hello {{ name }}")
    end

    it "fetch_and_compile delegates to instance with default adapter" do
      allow_any_instance_of(LlmEvalRuby::ApiClients::Langfuse)
        .to receive(:fetch_prompt)
        .with(name: "my_prompt", version: nil)
        .and_return(prompt_response)

      result = described_class.fetch_and_compile(name: "my_prompt", variables: { name: "Charlie" })

      expect(result).to be_a(LlmEvalRuby::PromptTypes::Compiled)
      expect(result.content).to eq("Hello Charlie")
    end
  end
end
