# frozen_string_literal: true

def mock_pro_grammar(*args)
  args.flatten!
  binding = args.first.is_a?(Binding) ? args.shift : binding()
  options = args.last.is_a?(Hash) ? args.pop : {}

  input = InputTester.new(*args)
  output = StringIO.new

  redirect_pro_grammar_io(input, output) do
    binding.pro_grammar(options)
  end

  output.string
end

# Set I/O streams. Out defaults to an anonymous StringIO.
def redirect_pro_grammar_io(new_in, new_out = StringIO.new)
  old_in = ProGrammar.config.input
  old_out = ProGrammar.config.output

  ProGrammar.config.input = new_in
  ProGrammar.config.output = new_out
  begin
    yield
  ensure
    ProGrammar.config.input = old_in
    ProGrammar.config.output = old_out
  end
end

class InputTester
  def initialize(*actions)
    @orig_actions = actions.dup
    @actions = actions
  end

  def readline(*)
    @actions.shift
  end

  def rewind
    @actions = @orig_actions.dup
  end
end
