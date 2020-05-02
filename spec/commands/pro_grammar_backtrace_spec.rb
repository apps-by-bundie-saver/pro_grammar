# frozen_string_literal: true

describe "pro_grammar_backtrace" do
  before do
    @t = pro_grammar_tester
  end

  it 'should print a backtrace' do
    @t.process_command 'pro_grammar-backtrace'
    expect(@t.last_output).to start_with('Backtrace:')
  end
end
