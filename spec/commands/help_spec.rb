# frozen_string_literal: true

describe "help" do
  before do
    @oldset = ProGrammar.config.commands
    @set = ProGrammar.config.commands = ProGrammar::CommandSet.new do
      import ProGrammar::Commands
    end
  end

  after do
    ProGrammar.config.commands = @oldset
  end

  it 'should display help for a specific command' do
    expect(pro_grammar_eval('help ls')).to match(/Usage: ls/)
  end

  it 'should display help for a regex command with a "listing"' do
    @set.command(/bar(.*)/, "Test listing", listing: "foo") { ; }
    expect(pro_grammar_eval('help foo')).to match(/Test listing/)
  end

  it 'should display help for a command with a spaces in its name' do
    @set.command('cmd with spaces', 'desc of a cmd with spaces') {}
    expect(pro_grammar_eval('help "cmd with spaces"')).to match(/desc of a cmd with spaces/)
  end

  it 'should display help for all commands with a description' do
    @set.command(/bar(.*)/, "Test listing", listing: "foo") { ; }
    @set.command('b', 'description for b', listing: 'foo') {}
    @set.command('c') {}
    @set.command('d', '') {}

    output = pro_grammar_eval('help')
    expect(output).to match(/Test listing/)
    expect(output).to match(/Description for b/)
    expect(output).to match(/No description/)
  end

  it "should sort the output of the 'help' command" do
    @set.command('faa', 'Fooerizes') {}
    @set.command('gaa', 'Gooerizes') {}
    @set.command('maa', 'Mooerizes') {}
    @set.command('baa', 'Booerizes') {}

    doc = pro_grammar_eval('help')

    order = [doc.index("baa"),
             doc.index("faa"),
             doc.index("gaa"),
             doc.index("maa")]

    expect(order).to eq(order.sort)
  end
end
