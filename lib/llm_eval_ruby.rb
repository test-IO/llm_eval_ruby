# frozen_string_literal: true

require_relative "llm_eval_ruby/version"
require_relative "llm_eval_ruby/prompt_repository"
require_relative "llm_eval_ruby/configuration"

module LlmEvalRuby
  class Error < StandardError; end

  def self.configure
    yield config if block_given?
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.config
    configuration
  end
end
