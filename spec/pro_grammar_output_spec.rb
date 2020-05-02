# frozen_string_literal: true

describe ProGrammar do
  describe "output failsafe" do
    after { ProGrammar.config.print = ProGrammar::Config.new.print }

    it "should catch serialization exceptions" do
      ProGrammar.config.print = proc { raise "catch-22" }

      expect { mock_pro_grammar("1") }.to_not raise_error
    end

    it "should display serialization exceptions" do
      ProGrammar.config.print = proc { raise "catch-22" }

      expect(mock_pro_grammar("1")).to match(/\(pro_grammar\) output error: #<RuntimeError: catch-22>/)
    end

    it "should catch errors serializing exceptions" do
      ProGrammar.config.print = proc do
        ex = Exception.new("catch-22")
        class << ex
          def inspect
            raise ex
          end
        end
        raise ex
      end

      expect(mock_pro_grammar("1")).to match(/\(pro_grammar\) output error: failed to show result/)
    end
  end

  describe "default print" do
    it "should output the right thing" do
      expect(mock_pro_grammar("[1]")).to match(/^=> \[1\]/)
    end

    it "should include the =>" do
      pro_grammar = ProGrammar.new
      accumulator = StringIO.new
      pro_grammar.config.output = accumulator
      pro_grammar.config.print.call(accumulator, [1], pro_grammar)
      expect(accumulator.string).to eq("=> \[1\]\n")
    end

    it "should not be phased by un-inspectable things" do
      expect(mock_pro_grammar("class NastyClass; undef pretty_inspect; end", "NastyClass.new"))
        .to match(/#<.*NastyClass:0x.*?>/)
    end

    it "doesn't leak colour for object literals" do
      expect(mock_pro_grammar("Object.new")).to match(/=> #<Object:0x[a-z0-9]+>\n/)
    end
  end

  describe "output_prefix" do
    it "should be able to change output_prefix" do
      pro_grammar = ProGrammar.new
      accumulator = StringIO.new
      pro_grammar.config.output = accumulator
      pro_grammar.config.output_prefix = "-> "
      pro_grammar.config.print.call(accumulator, [1], pro_grammar)
      expect(accumulator.string).to eq("-> \[1\]\n")
    end
  end

  describe "color" do
    before do
      ProGrammar.config.color = true
    end

    after do
      ProGrammar.config.color = false
    end

    it "should colorize strings as though they were ruby" do
      pro_grammar = ProGrammar.new
      accumulator = StringIO.new
      colorized = ProGrammar::SyntaxHighlighter.highlight('[1]')
      pro_grammar.config.output = accumulator
      pro_grammar.config.print.call(accumulator, [1], pro_grammar)
      expect(accumulator.string).to eq("=> #{colorized}\n")
    end

    it "should not colorize strings that already include color" do
      pro_grammar = ProGrammar.new
      f = Object.new
      def f.inspect
        "\e[1;31mFoo\e[0m"
      end
      accumulator = StringIO.new
      pro_grammar.config.output = accumulator
      pro_grammar.config.print.call(accumulator, f, pro_grammar)
      # We add an extra \e[0m to prevent color leak
      expect(accumulator.string).to eq("=> \e[1;31mFoo\e[0m\e[0m\n")
    end
  end

  describe "output suppression" do
    before do
      @t = pro_grammar_tester
    end
    it "should normally output the result" do
      expect(mock_pro_grammar("1 + 2")).to eq("=> 3\n")
    end

    it "should not output anything if the input ends with a semicolon" do
      expect(mock_pro_grammar("1 + 2;")).to eq("")
    end

    it "should output something if the input ends with a comment" do
      expect(mock_pro_grammar("1 + 2 # basic addition")).to eq("=> 3\n")
    end

    it "should not output something if the input is only a comment" do
      expect(mock_pro_grammar("# basic addition")).to eq("")
    end
  end

  describe "custom non-IO object as $stdout" do
    it "does not crash pro_grammar" do
      old_stdout = $stdout
      pro_grammar_eval = pro_grammar_tester(binding)
      expect(pro_grammar_eval.eval("$stdout = Class.new { def write(*) end }.new", ":ok"))
        .to eq(:ok)
      $stdout = old_stdout
    end
  end
end
