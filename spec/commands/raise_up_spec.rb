# frozen_string_literal: true

describe "raise-up" do
  before do
    @self  = "Pad.self = self"
    @inner = "Pad.inner = self"
    @outer = "Pad.outer = self"
  end

  after do
    Pad.clear
  end

  it "should raise the exception with raise-up" do
    redirect_pro_grammar_io(InputTester.new("raise NoMethodError", "raise-up NoMethodError")) do
      expect { Object.new.pro_grammar }.to raise_error NoMethodError
    end
  end

  it "should raise an unamed exception with raise-up" do
    redirect_pro_grammar_io(InputTester.new("raise 'stop'", "raise-up 'noreally'")) do
      expect { Object.new.pro_grammar }.to raise_error(RuntimeError, "noreally")
    end
  end

  it "should eat the exception at the last new pro_grammar instance on raise-up" do
    redirect_pro_grammar_io(InputTester.new(":inner.pro_grammar", "raise NoMethodError", @inner,
                                    "raise-up NoMethodError", @outer, "exit-all")) do
      ProGrammar.start(:outer)
    end

    expect(Pad.inner).to eq :inner
    expect(Pad.outer).to eq :outer
  end

  it "should raise the most recently raised exception" do
    expect { mock_pro_grammar("raise NameError, 'homographery'", "raise-up") }
      .to raise_error(NameError, 'homographery')
  end

  it "should allow you to cd up and (eventually) out" do
    redirect_pro_grammar_io(InputTester.new("cd :inner", "raise NoMethodError", @inner,
                                    "deep = :deep", "cd deep", "Pad.deep = self",
                                    "raise-up NoMethodError", "raise-up", @outer,
                                    "raise-up", "exit-all")) do
      expect { ProGrammar.start(:outer) }.to raise_error NoMethodError
    end

    expect(Pad.deep).to  eq :deep
    expect(Pad.inner).to eq :inner
    expect(Pad.outer).to eq :outer
  end

  it "should jump immediately out of nested contexts with !" do
    expect { mock_pro_grammar("cd 1", "cd 2", "cd 3", "raise-up! 'fancy that...'") }
      .to raise_error(RuntimeError, 'fancy that...')
  end
end
