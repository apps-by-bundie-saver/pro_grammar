# frozen_string_literal: true

describe ProGrammar::REPL do
  it "should let you run commands in the middle of multiline expressions" do
    ReplTester.start do
      input  'def a'
      input  '!'
      output(/^Input buffer cleared/)

      input  '5'
      output '=> 5'
    end
  end

  it "should rescue exceptions" do
    ReplTester.start do
      input  'raise "lorum"'
      output(/^RuntimeError: lorum/)

      if defined?(java)
        input 'raise java.lang.Exception.new("foo")'
        output(/Exception: foo/)

        input 'raise java.io.IOException.new("bar")'
        output(/IOException: bar/)
      end
    end
  end

  describe "eval_string and binding_stack" do
    it "shouldn't break if we start a nested REPL" do
      ReplTester.start do
        input  'ProGrammar::REPL.new(pro_grammar_instance, :target => 10).start'
        output ''
        prompt(/10.*> $/)

        input  'self'
        output '=> 10'

        input  nil # Ctrl-D
        output ''

        input  'self'
        output '=> main'
      end
    end

    it "shouldn't break if we start a nested instance" do
      ReplTester.start do
        input  'ProGrammar.start(10)'
        output ''
        prompt(/10.*> $/)

        input  'self'
        output '=> 10'

        input  nil # Ctrl-D
        output '=> nil' # return value of ProGrammar session

        input  'self'
        output '=> main'
      end
    end

    it "shouldn't break if we pop bindings in Ruby" do
      ReplTester.start do
        input  'cd 10'
        output ''
        prompt(/10.*> $/)

        input 'pro_grammar_instance.binding_stack.pop'
        output(/^=> #<Binding/)
        prompt(/main.*> $/)

        input 'pro_grammar_instance.binding_stack.pop'
        output(/^=> #<Binding/)
        assert_exited
      end
    end

    it "should immediately evaluate eval_string after cmd if complete" do
      set = ProGrammar::CommandSet.new do
        import ProGrammar::Commands

        command 'hello!' do
          eval_string.replace('"hello"')
        end
      end

      ReplTester.start(commands: set) do
        input  'def x'
        output ''
        prompt(/\*   $/)

        input  'hello!'
        output '=> "hello"'
        prompt(/> $/)
      end
    end
  end

  describe "space prefix" do
    describe "with 1 space" do
      it "it prioritizes variables over commands" do
        expect(pro_grammar_eval(' ls = 2+2', ' ls')).to eq(4)
      end
    end

    describe "with more than 1 space" do
      it "prioritizes commands over variables" do
        expect(mock_pro_grammar('    ls = 2+2')).to match(/SyntaxError.+unexpected '='/)
      end
    end
  end

  describe "#piping?" do
    it "returns false when $stdout is a non-IO object" do
      repl = described_class.new(ProGrammar.new, {})
      old_stdout = $stdout
      $stdout = Class.new { def write(*) end }.new
      expect(repl.send(:piping?)).to eq(false)
      $stdout = old_stdout
    end
  end

  describe "autoindent" do
    it "should raise no exception when indented with a tab" do
      ReplTester.start(correct_indent: true, auto_indent: true) do
        output = @pro_grammar.config.output
        def output.tty?
          true
        end
        input <<TAB
loop do
	break #note the tab here
end
TAB
        output("do\n  break #note the tab here\nend\n\e[1B\e[0G=> nil")
      end
    end
  end
end
