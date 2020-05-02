# frozen_string_literal: true

describe "exit-all" do
  before { @pro_grammar = ProGrammar.new }

  it "should break out of the repl and return nil" do
    expect(@pro_grammar.eval("exit-all")).to equal false
    expect(@pro_grammar.exit_value).to equal nil
  end

  it "should break out of the repl wth a user specified value" do
    expect(@pro_grammar.eval("exit-all 'message'")).to equal false
    expect(@pro_grammar.exit_value).to eq("message")
  end

  it "should break out of the repl even if multiple bindings still on stack" do
    ["cd 1", "cd 2"].each { |line| expect(@pro_grammar.eval(line)).to equal true }
    expect(@pro_grammar.eval("exit-all 'message'")).to equal false
    expect(@pro_grammar.exit_value).to eq("message")
  end

  it "should have empty binding_stack after breaking out of the repl" do
    ["cd 1", "cd 2"].each { |line| expect(@pro_grammar.eval(line)).to equal true }
    expect(@pro_grammar.eval("exit-all")).to equal false
    expect(@pro_grammar.binding_stack).to be_empty
  end
end
