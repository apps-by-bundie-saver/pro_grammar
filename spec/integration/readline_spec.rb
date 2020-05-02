# frozen_string_literal: true

# These specs ensure that ProGrammar doesn't require readline until the first time a
# REPL is started.

require "shellwords"
require 'rbconfig'

RSpec.describe "Readline" do
  before :all do
    @ruby = RbConfig.ruby.shellescape
    @pro_grammar_dir = File.expand_path(File.join(__FILE__, '../../../lib')).shellescape
  end

  it "is not loaded on requiring 'pro_grammar'" do
    code = <<-RUBY
      require "pro_grammar"
      p defined?(Readline)
    RUBY
    expect(`#{@ruby} -I #{@pro_grammar_dir} -e '#{code}'`).to eq("nil\n")
  end

  it "is loaded on invoking 'pro_grammar'" do
    code = <<-RUBY
      require "pro_grammar"
      ProGrammar.start self, input: StringIO.new("exit-all"), output: StringIO.new
      puts defined?(Readline)
    RUBY
    expect(`#{@ruby} -I #{@pro_grammar_dir} -e '#{code}'`.end_with?("constant\n")).to eq(true)
  end

  it "is not loaded on invoking 'pro_grammar' if ProGrammar.input is set" do
    code = <<-RUBY
      require "pro_grammar"
      ProGrammar.input = StringIO.new("exit-all")
      ProGrammar.start self, output: StringIO.new
      p defined?(Readline)
    RUBY
    expect(`#{@ruby} -I #{@pro_grammar_dir} -e '#{code}'`.end_with?("nil\n")).to eq(true)
  end
end
