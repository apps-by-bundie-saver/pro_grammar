# frozen_string_literal: true

describe "exit" do
  before { @pro_grammar = ProGrammar.new(target: :outer, output: StringIO.new) }

  it "should pop a binding" do
    @pro_grammar.eval "cd :inner"
    expect(@pro_grammar.evaluate_ruby("self")).to eq :inner
    @pro_grammar.eval "exit"
    expect(@pro_grammar.evaluate_ruby("self")).to eq :outer
  end

  it "should break out of the repl when binding_stack has only one binding" do
    expect(@pro_grammar.eval("exit")).to equal false
    expect(@pro_grammar.exit_value).to equal nil
  end

  it "should break out of the repl and return user-given value" do
    expect(@pro_grammar.eval("exit :john")).to equal false
    expect(@pro_grammar.exit_value).to eq :john
  end

  it "should break out of the repl even after an exception" do
    @pro_grammar.eval "exit = 42"
    expect(@pro_grammar.output.string).to match(/^SyntaxError/)
    expect(@pro_grammar.eval("exit")).to equal false
  end
end
